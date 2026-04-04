class ChapterLayerItemsController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!
  before_action :set_layer, only: [:create, :reorder, :insert_after, :suggest_hint_translations_batch]
  before_action :set_item, only: [:update, :destroy, :suggest_hint_translation, :upsert_sub_layer_item, :generate_block_wizard]

  def create
    @item = @layer.chapter_layer_items.new(item_params)
    if @item.save
      render json: @item.as_json, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # POST /chapter_layers/:chapter_layer_id/chapter_layer_items/insert_after
  # body: { after_id: optional item id, chapter_layer_item: { body, style, hint } }
  # Efficient middle insert: one bulk shift + one insert in a transaction.
  def insert_after
    after_id = params[:after_id]
    insert_pos = if after_id.present?
      ref = @layer.chapter_layer_items.find(after_id)
      ref.position + 1
    else
      0
    end

    created = nil
    ChapterLayerItem.transaction do
      @layer.chapter_layer_items.where("position >= ?", insert_pos).update_all("position = position + 1")
      created = @layer.chapter_layer_items.create!(item_params.merge(position: insert_pos))
    end

    render json: created.as_json, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: "after_id not found in this layer" }, status: :unprocessable_entity
  end

  def update
    if @item.update(item_params)
      render json: @item.as_json
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # PATCH /chapter_layer_items/:id/sub_layer_item
  # body: { chapter_sublayer_id: Integer, body: String, hint: optional String }
  def upsert_sub_layer_item
    sublayer = LanguageChapterSublayer.find(params.require(:chapter_sublayer_id))
    if @item.chapter_layer&.chapter&.language_id != sublayer.language_id
      return render json: { error: "Sublayer language does not match this chapter item language" }, status: :unprocessable_entity
    end

    sli = SubLayerItem.find_or_initialize_by(
      language_chapter_sublayer_id: sublayer.id,
      sublayer_itemable: @item
    )
    sli.language_id = sublayer.language_id
    sli.body = params[:body].to_s
    sli.hint = params[:hint].to_s if params.key?(:hint)
    sli.save!

    render json: {
      sub_layer_item: {
        id: sli.id,
        language_chapter_sublayer_id: sli.language_chapter_sublayer_id,
        sublayer_itemable_type: sli.sublayer_itemable_type,
        sublayer_itemable_id: sli.sublayer_itemable_id,
        body: sli.body,
        hint: sli.hint
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "chapter_sublayer_id not found" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  # POST /chapter_layer_items/:id/suggest_hint_translation
  # Uses WizardService to suggest a concise English hint for this item body.
  def suggest_hint_translation
    source_text = LayerItemHintTranslator.plain_text(@item.body)
    if source_text.blank?
      return render json: { error: "Item body is empty" }, status: :unprocessable_entity
    end

    suggestion = suggestion_for_item(@item, source_text, prior_passage_pairs: nil)
    if suggestion.blank?
      return render json: { error: "Item body is empty" }, status: :unprocessable_entity
    end

    render json: { suggestion: suggestion }
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /chapter_layers/:chapter_layer_id/chapter_layer_items/suggest_hint_translations_batch
  # body: { start_item_id: 123, count: 20, prior_passage: [ { source: "...", translation: "..." }, ... ] }
  # Optional prior_passage = all earlier items in the layer (in order) so later batches stay consistent.
  # Within one request, each item also sees translations produced earlier in the same batch.
  def suggest_hint_translations_batch
    start_item = @layer.chapter_layer_items.find(params.require(:start_item_id))
    requested = params[:count].to_i
    count = requested > 0 ? [requested, 20].min : 20

    items = @layer.chapter_layer_items
      .where("position >= ?", start_item.position)
      .order(:position, :id)
      .limit(count)

    accumulated = prior_passage_pairs_from_params
    suggestions = []
    items.each do |item|
      source_text = LayerItemHintTranslator.plain_text(item.body)
      next if source_text.blank?

      suggestion = suggestion_for_item(item, source_text, prior_passage_pairs: accumulated)
      next if suggestion.blank?

      suggestions << { id: item.id, suggestion: suggestion }
      accumulated << { "source" => source_text, "translation" => suggestion }
    end

    render json: { suggestions: suggestions }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "start_item_id not found in this layer" }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /chapter_layer_items/:id/generate_block_wizard
  # body: { language_chapter_blockable_set_id:, payload_text?: optional override }
  def generate_block_wizard
    set_id = params.require(:language_chapter_blockable_set_id)
    set = LanguageChapterBlockableSet.find(set_id)
    chapter = @item.chapter_layer.chapter
    if set.language_id != chapter.language_id
      return render json: { error: "Blockable set belongs to a different language" }, status: :unprocessable_entity
    end

    if set.language_chapter_blockable_options.empty?
      return render json: { error: "Blockable set has no options. Add options before generating." }, status: :unprocessable_entity
    end

    payload_text = params[:payload_text].to_s.strip.presence
    payload_text ||= LayerItemHintTranslator.plain_text(@item.body)

    prompt = BlockableSetWizardPromptBuilder.build_combined_prompt(set: set, payload_text: payload_text.to_s)
    expected_json = BlockableSetWizardPromptBuilder.build_expected_json_string(set: set)

    result = BlockableSetWizardRunner.run!(prompt: prompt, expected_json: expected_json)
    unless result[:ok] && result[:items].is_a?(Array)
      msg = result[:error].presence || "Wizard did not return an items array"
      return render json: { error: msg, parsed: result[:parsed] }, status: :unprocessable_entity
    end

    display_keys = BlockableSetWizardPromptBuilder.display_keys_for_set(set: set)
    details = {
      "items" => result[:items],
      "display_keys" => display_keys
    }

    # Drop every ChapterLayerBlock tied to this set on this item (handles duplicates), then persist one fresh row.
    ChapterLayerBlock.transaction do
      @item.chapter_layer_blocks.where(blockable_type: "LanguageChapterBlockableSet", blockable_id: set.id).delete_all
      @item.chapter_layer_blocks.create!(
        blockable: set,
        position: set.position || set.id,
        details: details
      )
    end

    @item.reload
    render json: {
      chapter_layer_blocks: @item.chapter_layer_blocks.includes(:blockable).order(:position, :id).map(&:as_json_for_chapter),
      items: result[:items]
    }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @item.destroy!
    head :no_content
  end

  def reorder
    ids = params.require(:ordered_ids)
    unless ids.is_a?(Array)
      return render json: { error: "ordered_ids must be an array" }, status: :unprocessable_entity
    end

    ChapterLayerItem.transaction do
      ids.each_with_index do |item_id, idx|
        @layer.chapter_layer_items.find(item_id).update!(position: idx)
      end
    end
    head :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invalid item id" }, status: :unprocessable_entity
  end

  private

  def set_layer
    @layer = ChapterLayer.find(params[:chapter_layer_id])
  end

  def set_item
    @item = ChapterLayerItem.find(params[:id])
  end

  def item_params
    params.require(:chapter_layer_item).permit(:body, :style, :hint, :position)
  end

  def prior_passage_pairs_from_params
    raw = params[:prior_passage]
    return [] unless raw.is_a?(Array)

    raw.filter_map do |h|
      next unless h.is_a?(Hash)

      h = h.stringify_keys
      src = h["source"].to_s.gsub(/\s+/, " ").strip
      next if src.blank?

      tr = h["translation"].to_s.gsub(/\s+/, " ").strip
      { "source" => src, "translation" => tr }
    end
  end

  def suggestion_for_item(item, source_text, prior_passage_pairs:)
    language_title = item.chapter_layer&.chapter&.language&.title.to_s.presence || "the source language"
    previous_lines = prior_passage_pairs.present? ? nil : LayerItemHintTranslator.previous_source_lines_for_item(item, limit: 3)

    LayerItemHintTranslator.translate(
      source_text,
      language_title: language_title,
      prior_passage_pairs: prior_passage_pairs,
      previous_source_lines: previous_lines
    )
  end
end
