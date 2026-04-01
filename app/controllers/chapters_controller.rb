require "fileutils"
require "json"
require "net/http"
require "tmpdir"

class ChaptersController < ApplicationController
  include ApiAuthenticatable

  before_action :set_language, only: [:for_language, :create, :wizard_movie_summary]
  before_action :set_chapter, only: [:show, :update, :destroy, :move, :split_single_item, :bubbles_zip]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy, :move, :split_single_item, :wizard_movie_summary, :bubbles_zip]

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
    per_page = [[params[:items_per_page].to_i, 1].max, 200].min
    per_page = 80 if params[:items_per_page].blank?
    page = [params[:items_page].to_i, 1].max
    pagination_requested = params[:items_per_page].present? || params[:items_page].present? || params[:items_layer_id].present?
    default_layer_id = layers_rel.find(&:is_default)&.id || layers_rel.first&.id
    paged_layer_id = if pagination_requested
      requested = params[:items_layer_id].presence&.to_i
      requested.presence || default_layer_id
    end

    chapter_layers_json = layers_rel.map do |l|
      if pagination_requested
        include_items = l.id == paged_layer_id
        offset = include_items ? (page - 1) * per_page : 0
        limit = include_items ? per_page : 0
        l.as_json_for_viewer(
          admin: admin,
          include_items: include_items,
          items_offset: offset,
          items_limit: limit
        )
      else
        l.as_json_for_viewer(admin: admin)
      end
    end

    render json: {
      chapter: @chapter.as_json(only: %i[id title description chapter_mode tier chapter_id position language_id]),
      chapter_images: @chapter.chapter_images.order(:position, :id).as_json(only: %i[id chapter_id image_url original_filename position]),
      language: {
        id: @chapter.language_id,
        direction: @chapter.language&.direction
      },
      chapter_layers: chapter_layers_json,
      items_layer_id: paged_layer_id,
      items_page: page,
      items_per_page: per_page,
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

  def wizard_movie_summary
    title = params[:title].to_s.strip
    return render json: { error: "title is required" }, status: :unprocessable_entity if title.blank?

    language_title = @language.title.to_s.presence || "the language"
    summary = generate_long_movie_summary(language_title: language_title, title: title)
    return render json: { error: "Could not generate movie summary right now. Please try again." }, status: :unprocessable_entity if wizard_refusal?(summary)

    render json: { body: summary }
  rescue StandardError => e
    Rails.logger.error("[wizard_movie_summary] language #{@language&.id}: #{e.class}: #{e.message}")
    render json: { error: "Could not generate movie summary." }, status: :unprocessable_entity
  end

  # GET /chapters/:id/bubbles_zip
  # Produces indexed file pairs for pages with bubbles only:
  #   001.jpg + 001.json, 002.png + 002.json, ...
  def bubbles_zip
    images = @chapter.chapter_images.includes(:chapter_image_overlays).order(:position, :id)
    pages = images.select { |img| img.chapter_image_overlays.any? }
    return render json: { error: "No pages with bubbles to export." }, status: :unprocessable_entity if pages.empty?

    zip_filename = "chapter-#{@chapter.id}-bubble-pages.zip"
    zip_data = nil

    Dir.mktmpdir("chapter-#{@chapter.id}-bubbles-") do |dir|
      pages.each_with_index do |img, idx|
        base = format("%03d", idx + 1)
        ext = export_image_extension(img.image_url)
        image_bytes, mime_type = download_remote_image(img.image_url)
        File.binwrite(File.join(dir, "#{base}#{ext}"), image_bytes)

        overlays_payload = img.chapter_image_overlays.order(:position, :id).map do |o|
          {
            id: o.id,
            overlay_type: o.overlay_type,
            label: o.label,
            position: o.position,
            rotation: o.rotation,
            shape: o.shape,
            original: o.original,
            translation: o.translation
          }
        end

        page_payload = {
          index: idx + 1,
          chapter_id: @chapter.id,
          chapter_image_id: img.id,
          source_image_url: img.image_url,
          source_original_filename: img.original_filename,
          image_file: "#{base}#{ext}",
          image_mime_type: mime_type,
          overlays_count: overlays_payload.length,
          overlays: overlays_payload
        }
        File.write(File.join(dir, "#{base}.json"), JSON.pretty_generate(page_payload))
      end

      zip_path = File.join(Dir.tmpdir, "chapter-#{@chapter.id}-bubble-pages-#{SecureRandom.hex(6)}.zip")
      files_to_zip = Dir.glob(File.join(dir, "*")).sort
      ok = system("zip", "-j", "-q", zip_path, *files_to_zip)
      raise "zip command failed" unless ok && File.exist?(zip_path)

      zip_data = File.binread(zip_path)
      FileUtils.rm_f(zip_path)
    end

    send_data zip_data, filename: zip_filename, type: "application/zip", disposition: "attachment"
  rescue StandardError => e
    Rails.logger.error("[chapters_bubbles_zip] chapter #{@chapter&.id}: #{e.class}: #{e.message}")
    render json: { error: "Could not export bubbles zip." }, status: :unprocessable_entity
  end

  private

  def export_image_extension(url)
    path = URI.parse(url.to_s).path.to_s
    ext = File.extname(path).to_s.downcase
    allowed = %w[.jpg .jpeg .png .webp .gif]
    return ".jpg" if ext.blank? || !allowed.include?(ext)
    ext == ".jpeg" ? ".jpg" : ext
  rescue URI::InvalidURIError
    ".jpg"
  end

  def download_remote_image(url)
    uri = URI.parse(url.to_s)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    raise "failed to download image #{url}" unless response.is_a?(Net::HTTPSuccess)
    [response.body, response["content-type"].presence || "image/jpeg"]
  end

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

  def ask_wizard_fresh_text(prompt)
    session_id = SecureRandom.uuid
    client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "system",
            content: "This is an independent new chat session id #{session_id}. Ignore any prior conversation."
          },
          { role: "user", content: prompt }
        ],
        temperature: 0.7,
        response_format: { type: "text" }
      }
    )
    response.dig("choices", 0, "message", "content").to_s.strip
  end

  def generate_long_movie_summary(language_title:, title:)
    parts = []
    section_specs = [
      "Part 1 of 3: opening setup, key characters, and early plot developments.",
      "Part 2 of 3: middle arc, escalating conflict, and turning points.",
      "Part 3 of 3: late arc, climax, ending, and aftermath."
    ]

    section_specs.each_with_index do |section_instruction, idx|
      previous = parts.join("\n\n")
      prompt = <<~PROMPT
        Write in #{language_title}.
        Movie: #{title}
        #{section_instruction}
        Target length for this part: around 650-850 words.
        Output only plain paragraph text. No markdown. No bullets. No intro/disclaimer.
        Do not repeat prior parts.
        Prior parts for continuity:
        #{previous.present? ? previous : "(none yet)"}
      PROMPT

      part = ask_wizard_fresh_text(prompt)
      if wizard_refusal?(part)
        retry_prompt = <<~PROMPT
          Provide only the requested narrative recap section in #{language_title} for the movie #{title}.
          #{section_instruction}
          Plain paragraphs only.
        PROMPT
        part = ask_wizard_fresh_text(retry_prompt)
      end
      next if wizard_refusal?(part) || part.blank?

      parts << part.strip
      Rails.logger.info("[wizard_movie_summary] generated part #{idx + 1}/3 length=#{part.length}")
    end

    parts.join("\n\n")
  end

  def wizard_refusal?(text)
    s = text.to_s.downcase
    return true if s.blank?

    s.include?("i can't") ||
      s.include?("i cannot") ||
      s.include?("i'm sorry") ||
      s.include?("sorry, but i can't") ||
      s.include?("however, i can")
  end

  def set_chapter
    @chapter = Chapter.find(params[:id])
  end

  def chapter_params
    params.require(:chapter).permit(:title, :description, :chapter_mode, :tier, :chapter_id, :position)
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
