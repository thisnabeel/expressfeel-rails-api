class ChapterImageOverlaysController < ApplicationController
  include ApiAuthenticatable
  include ChapterImageOverlaySerialization

  before_action :set_chapter_image, only: [:index, :create]
  before_action :set_overlay, only: [:update, :destroy, :upsert_sub_layer_item, :generate_block_wizard]
  before_action :authenticate_api_admin!, only: [:create, :update, :destroy, :upsert_sub_layer_item, :generate_block_wizard]

  def index
    overlays = @chapter_image.chapter_image_overlays
      .includes(
        sub_layer_items: :language_chapter_sublayer,
        chapter_image_overlay_item_blocks: [:blockable, :chapter_image_overlay_item_block_fields]
      )
      .order(:position, :id)
    render json: { overlays: overlays.map { |o| serialize_overlay(o) } }
  end

  def create
    overlay = @chapter_image.chapter_image_overlays.create!(
      overlay_type: params.require(:overlay_type),
      shape: params.require(:shape),
      label: params[:label].presence,
      original: params[:original].to_s,
      translation: params[:translation].to_s,
      position: params[:position].presence&.to_i || next_position
    )
    overlay = ChapterImageOverlay.includes(
      sub_layer_items: :language_chapter_sublayer,
      chapter_image_overlay_item_blocks: [:blockable, :chapter_image_overlay_item_block_fields]
    ).find(overlay.id)
    render json: { overlay: serialize_overlay(overlay) }, status: :created
  end

  def update
    @overlay.update!(overlay_params)
    @overlay = ChapterImageOverlay.includes(
      sub_layer_items: :language_chapter_sublayer,
      chapter_image_overlay_item_blocks: [:blockable, :chapter_image_overlay_item_block_fields]
    ).find(@overlay.id)
    render json: { overlay: serialize_overlay(@overlay) }
  end

  def destroy
    @overlay.destroy!
    head :no_content
  end

  # PATCH /chapter_image_overlays/:id/sub_layer_item
  # body: { chapter_sublayer_id: Integer, body: String, hint: optional String }
  def upsert_sub_layer_item
    sublayer = LanguageChapterSublayer.find(params.require(:chapter_sublayer_id))
    chapter = @overlay.chapter_image&.chapter
    if chapter.blank? || chapter.language_id != sublayer.language_id
      return render json: { error: "Sublayer language does not match this chapter" }, status: :unprocessable_entity
    end

    sli = SubLayerItem.find_or_initialize_by(
      language_chapter_sublayer_id: sublayer.id,
      sublayer_itemable: @overlay
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

  # POST /chapter_image_overlays/:id/generate_block_wizard
  # body: { language_chapter_blockable_set_id:, payload_text?: optional override }
  def generate_block_wizard
    set_id = params.require(:language_chapter_blockable_set_id)
    set = LanguageChapterBlockableSet.find(set_id)
    chapter = @overlay.chapter_image&.chapter
    if chapter.blank? || set.language_id != chapter.language_id
      return render json: { error: "Blockable set belongs to a different language" }, status: :unprocessable_entity
    end

    if set.language_chapter_blockable_options.empty?
      return render json: { error: "Blockable set has no options. Add options before generating." }, status: :unprocessable_entity
    end

    payload_text = params[:payload_text].to_s.strip.presence
    payload_text ||= default_overlay_wizard_payload_text(@overlay)

    base_prompt = BlockableSetWizardPromptBuilder.build_combined_prompt(set: set, payload_text: payload_text.to_s)
    expected_json = BlockableSetWizardPromptBuilder.build_expected_json_string(set: set)
    display_keys = BlockableSetWizardPromptBuilder.display_keys_for_set(set: set)

    retry_feedback = nil
    attempt_errors = []
    last_result = nil
    max_attempts = ChapterLayerItemsController::MAX_BLOCK_WIZARD_ATTEMPTS

    max_attempts.times do |attempt_index|
      prompt = overlay_block_wizard_prompt_with_retry_context(base_prompt, retry_feedback, attempt_index, max_attempts)
      result = BlockableSetWizardRunner.run!(prompt: prompt, expected_json: expected_json)
      last_result = result

      unless result[:ok] && result[:items].is_a?(Array)
        msg = result[:error].presence || "Wizard did not return an items array"
        return render json: {
          error: msg,
          parsed: result[:parsed],
          wizard_attempts: attempt_index + 1,
          attempt_errors: attempt_errors + [{ "attempt" => attempt_index + 1, "phase" => "wizard", "error" => msg }]
        }, status: :unprocessable_entity
      end

      details = {
        "items" => result[:items],
        "display_keys" => display_keys
      }
      details = deep_scrub_overlay_wizard_jsonb(details)

      begin
        ActiveRecord::Base.transaction do
          BlockWizardBlockItemsSync.replace_overlay_strip!(@overlay, set, details)
        end

        @overlay.reload
        return render json: {
          chapter_layer_blocks: ChapterBlockableStripJson.overlay_strips(@overlay),
          items: result[:items],
          wizard_attempts: attempt_index + 1,
          attempt_errors: attempt_errors.presence
        }
      rescue ActiveRecord::StatementInvalid => e
        summary = overlay_statement_invalid_summary(e)
        attempt_errors << { "attempt" => attempt_index + 1, "phase" => "persist", "error" => summary }
        Rails.logger.warn("[overlay_generate_block_wizard] persist failed attempt #{attempt_index + 1}: #{summary}")
        retry_feedback = overlay_build_block_wizard_retry_feedback(summary)
        next
      end
    end

    last_persist_error = attempt_errors.reverse.find { |h| h["phase"] == "persist" }&.dig("error")
    render json: {
      error: last_persist_error.presence || "Could not persist wizard output after #{max_attempts} attempts.",
      parsed: last_result&.dig(:parsed),
      wizard_attempts: max_attempts,
      attempt_errors: attempt_errors
    }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_chapter_image
    @chapter_image = ChapterImage.find(params[:chapter_image_id])
  end

  def set_overlay
    @overlay = ChapterImageOverlay.find(params[:id])
  end

  def next_position
    @chapter_image.chapter_image_overlays.maximum(:position).to_i + 1
  end

  def overlay_params
    params.require(:overlay).permit(
      :label, :original, :translation, :position, :overlay_type, :rotation,
      shape: {}
    )
  end

  def default_overlay_wizard_payload_text(overlay)
    overlay.original.to_s.strip
  end

  PG_JSONB_SCRUB_REGEX = /[\u0000-\u0008\u000B\u000C\u000E-\u001F]/.freeze

  def deep_scrub_overlay_wizard_jsonb(value)
    case value
    when String
      value.gsub(PG_JSONB_SCRUB_REGEX, "")
    when Array
      value.map { |v| deep_scrub_overlay_wizard_jsonb(v) }
    when Hash
      value.transform_values { |v| deep_scrub_overlay_wizard_jsonb(v) }
    else
      value
    end
  end

  def overlay_statement_invalid_summary(exception)
    parts = [exception.message.to_s.strip]
    c = exception.cause
    if c.respond_to?(:message) && c.message.present?
      parts << "#{c.class}: #{c.message}".strip
    end
    parts.reject(&:blank?).join(" | ")
  end

  def overlay_build_block_wizard_retry_feedback(summary)
    <<~TXT.strip
      The database refused to store your previous "items" JSON. Details:
      #{summary.truncate(1800, omission: "…")}

      Fix: use only normal printable text in every string value. Do not include U+0000 (NUL) or other control characters.
      For Arabic verb citation use a real backslash with spaces, e.g. "فَعَلَ \\ يَفْعَلُ", not JSON unicode escapes that decode to NUL or invalid code points.
    TXT
  end

  def overlay_block_wizard_prompt_with_retry_context(base_prompt, retry_feedback, attempt_index, max_attempts)
    return base_prompt if retry_feedback.blank?

    suffix = <<~FEEDBACK
      ---
      RETRY #{attempt_index + 1}/#{max_attempts}: DATABASE REJECTED THE PREVIOUS OUTPUT
      #{retry_feedback}
    FEEDBACK

    combined = "#{base_prompt}\n\n#{suffix}"
    max_len = BlockableSetWizardRunner::MAX_PROMPT
    return combined if combined.length <= max_len

    room = max_len - base_prompt.length - 20
    return base_prompt if room < 200

    trimmed_suffix = suffix.truncate(room, omission: "…\n")
    "#{base_prompt}\n\n#{trimmed_suffix}"
  end
end
