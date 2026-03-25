class ChaptersController < ApplicationController
  include ApiAuthenticatable

  before_action :set_language, only: [:for_language, :create]
  before_action :set_chapter, only: [:show, :update, :destroy, :move, :split_single_item]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy, :move, :split_single_item]

  def for_language
    render json: { chapters: Chapter.tree_for_language(@language.id) }
  end

  def create
    initial_body = params.dig(:chapter, :initial_body)
    @chapter = @language.chapters.new(chapter_params)
    if @chapter.save
      process_initial_chapter_body(@chapter, initial_body)
      render json: @chapter.as_json, status: :created
    else
      render json: @chapter.errors, status: :unprocessable_entity
    end
  end

  def show
    optional_api_user
    admin = @api_user&.admin?
    layers_rel = @chapter.chapter_layers.ordered
    layers_rel = layers_rel.active_only unless admin
    render json: {
      chapter: @chapter.as_json(only: %i[id title description chapter_id position language_id]),
      language: {
        id: @chapter.language_id,
        direction: @chapter.language&.direction
      },
      chapter_layers: layers_rel.map { |l| l.as_json_for_viewer(admin: admin) },
      viewer_is_admin: admin == true
    }
  end

  def update
    if @chapter.update(chapter_params)
      render json: @chapter.as_json
    else
      render json: @chapter.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @chapter.destroy!
    head :no_content
  end

  # POST /chapters/:id/move — body: { delta: -1 | 1 } to swap with previous/next sibling
  def move
    delta = params.require(:delta).to_i
    unless [-1, 1].include?(delta)
      return render json: { error: "delta must be -1 or 1" }, status: :unprocessable_entity
    end

    sibs = Chapter.where(language_id: @chapter.language_id, chapter_id: @chapter.chapter_id).order(:position, :id).to_a
    i = sibs.index(@chapter)
    return head :unprocessable_entity unless i

    j = i + delta
    return head :unprocessable_entity if j.negative? || j >= sibs.length

    other = sibs[j]
    Chapter.transaction do
      p1 = @chapter.position
      p2 = other.position
      @chapter.update_columns(position: p2)
      other.update_columns(position: p1)
    end
    Chapter.renumber_siblings!(@chapter.language_id, @chapter.chapter_id)
    head :ok
  end

  # POST /chapters/:id/split_single_item
  # body: { source_item_id: Integer, source_layer_id: Integer }
  # Splits one item into many in a NEW layer, in one transaction.
  def split_single_item
    source_layer = @chapter.chapter_layers.find(params.require(:source_layer_id))
    source_item = source_layer.chapter_layer_items.find(params.require(:source_item_id))

    new_layer = nil
    rows = []
    now = Time.current

    Chapter.transaction do
      new_layer = @chapter.chapter_layers.create!(
        title: "#{source_layer.title.presence || 'Layer'} (Split)",
        active: true,
        is_default: false,
        position: @chapter.chapter_layers.count
      )

      pieces = split_item_html(source_item.body, fallback_style: source_item.style)
      pos = 0
      pieces.each do |p|
        rows << {
          chapter_layer_id: new_layer.id,
          body: p[:body],
          style: p[:style],
          hint: "",
          position: pos,
          created_at: now,
          updated_at: now
        }
        pos += 1
      end

      ChapterLayerItem.insert_all!(rows) if rows.any?
    end

    render json: { layer_id: new_layer.id, created_items_count: rows.length }, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Source item/layer not found" }, status: :unprocessable_entity
  end

  private

  # Optional HTML body: split into items (same rules as split_single_item), insert into a new
  # layer "Passage" and set it as the default tab. The auto-created "main" layer stays (empty).
  # Then fill English hints via WizardService in order (cumulative context).
  def process_initial_chapter_body(chapter, html)
    return if html.blank?

    plain = LayerItemHintTranslator.plain_text(html)
    return if plain.blank?

    pieces = split_item_html(html.to_s, fallback_style: "inline")
    return if pieces.empty?

    target_layer = nil
    Chapter.transaction do
      chapter.reload
      max_pos = chapter.chapter_layers.maximum(:position)
      next_pos = max_pos.nil? ? 0 : max_pos + 1

      target_layer = chapter.chapter_layers.create!(
        title: "Passage",
        active: true,
        is_default: true,
        position: next_pos
      )
      chapter.chapter_layers.where.not(id: target_layer.id).update_all(is_default: false)

      now = Time.current
      rows = pieces.each_with_index.map do |p, idx|
        {
          chapter_layer_id: target_layer.id,
          body: p[:body],
          style: p[:style],
          hint: "",
          position: idx,
          created_at: now,
          updated_at: now
        }
      end

      ChapterLayerItem.insert_all!(rows) if rows.any?
    end

    target_layer&.reload
    fill_initial_layer_hints(target_layer, chapter.language) if target_layer
  rescue StandardError => e
    Rails.logger.error("[process_initial_chapter_body] chapter #{chapter&.id}: #{e.class}: #{e.message}")
  end

  def fill_initial_layer_hints(layer, language)
    return unless layer && language

    language_title = language.title.to_s.presence || "the source language"
    accumulated = []

    layer.chapter_layer_items.order(:position, :id).each do |item|
      next if %w[line_break hr].include?(item.style)

      source_text = LayerItemHintTranslator.plain_text(item.body)
      next if source_text.blank?

      hint = begin
        LayerItemHintTranslator.translate(
          source_text,
          language_title: language_title,
          prior_passage_pairs: accumulated,
          previous_source_lines: nil
        )
      rescue StandardError => e
        Rails.logger.error("[fill_initial_layer_hints] item #{item.id}: #{e.class}: #{e.message}")
        ""
      end

      item.update_columns(hint: hint, updated_at: Time.current) if hint.present?
      accumulated << { "source" => source_text, "translation" => hint }
    end
  end

  def set_language
    @language = Language.find(params[:language_id])
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :description, :chapter_id, :position)
  end

  # Converts rich HTML into many items preserving block/list structure.
  def split_item_html(html, fallback_style:)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
    blocks = []

    fragment.children.each do |node|
      if node.text?
        t = squash(node.text)
        blocks << { style: fallback_style, text: t } if t.present?
        next
      end
      next unless node.element?

      tag = node.name.downcase
      case tag
      when "blockquote"
        t = squash(node.text)
        blocks << { style: "quote", text: t } if t.present?
      when "ul"
        node.css("li").each do |li|
          t = squash(li.text)
          blocks << { style: "bullet", text: t } if t.present?
        end
      when "ol"
        node.css("li").each do |li|
          t = squash(li.text)
          blocks << { style: "ordered", text: t } if t.present?
        end
      else
        if tag.match?(/\Ah[1-6]\z/)
          t = squash(node.text)
          blocks << { style: "header", text: t } if t.present?
        else
          t = squash(node.text)
          blocks << { style: fallback_style, text: t } if t.present?
        end
      end
    end

    if blocks.empty?
      t = squash(fragment.text)
      blocks << { style: fallback_style, text: t } if t.present?
    end

    out = []
    blocks.each_with_index do |b, idx|
      split_sentences(b[:text]).each do |piece|
        safe = ERB::Util.html_escape(piece)
        out << { style: b[:style], body: safe }
      end
      out << { style: "line_break", body: "" } if idx < blocks.length - 1
    end
    out
  end

  def split_sentences(text)
    clean = squash(text)
    return [] if clean.blank?

    re = /[^.!?؟،,:;]+[.!?؟،,:;]*/
    matches = clean.scan(re).map { |s| squash(s) }.reject(&:blank?)
    matches.presence || [clean]
  end

  def squash(text)
    text.to_s.gsub(/\s+/, " ").strip
  end
end
