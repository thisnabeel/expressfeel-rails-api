class WizardController < ApplicationController
  include ApiAuthenticatable

  before_action :authenticate_api_admin!, only: [:block_set_testing, :block_tile_remix]

  def extract_manga_text
    image_base64 = params[:image_base64].to_s
    return render json: { error: "image_base64 is required" }, status: :unprocessable_entity if image_base64.blank?

    image_mime_type = params[:image_mime_type].presence || "image/png"
    prompt = <<~PROMPT
      You are extracting text from a manga speech-bubble cutout.
      Return ONLY a JSON object with:
      - original_arabic: the exact Arabic text in the image (no explanation)
      - translation: an English translation of that Arabic text
      If text is unclear, make your best attempt and keep output concise.
    PROMPT

    result = WizardService.ask_with_image(
      prompt: prompt,
      image_base64: image_base64,
      image_mime_type: image_mime_type,
      response_format: "json_object"
    )

    extracted_original, translation = normalize_result(result)

    # Retry with plain-text contract if JSON mode omitted expected fields.
    if extracted_original.blank? || translation.blank?
      text_prompt = <<~PROMPT
        Read the manga speech-bubble image and respond with EXACTLY two lines:
        ARABIC: <the extracted Arabic text>
        TRANSLATION: <English translation>
        No markdown, no code block, no extra lines.
      PROMPT
      text_result = WizardService.ask_with_image(
        prompt: text_prompt,
        image_base64: image_base64,
        image_mime_type: image_mime_type,
        response_format: "text"
      )
      text_arabic, text_translation = parse_text_contract(text_result)
      extracted_original = extracted_original.presence || text_arabic
      translation = translation.presence || text_translation
    end

    if extracted_original.blank?
      extracted_original = "No Arabic text extracted."
    end
    if translation.blank?
      translation = "No translation returned."
    end

    render json: {
      original: extracted_original.to_s,
      translation: translation.to_s
    }
  rescue StandardError => e
    Rails.logger.error("[wizard_extract_manga_text] #{e.class}: #{e.message}")
    render json: { error: "Could not extract text right now." }, status: :unprocessable_entity
  end

  # Translates the Arabic (or source) line the editor typed—no image.
  def translate_text
    text = params[:text].to_s.strip
    return render json: { error: "text is required" }, status: :unprocessable_entity if text.blank?
    return render json: { error: "text is too long (max 4000 characters)" }, status: :unprocessable_entity if text.length > 4000

    prompt = <<~PROMPT
      You translate manga or dialogue lines into natural English.
      Input text is usually Arabic script; it may rarely be another language.
      """
      #{text}
      """
      Return ONLY a JSON object with one key:
      - "translation": the English translation, concise and faithful to tone.
      If the input is not translatable, return {"translation": ""}.
    PROMPT

    result = WizardService.ask(prompt, "json_object")
    translation = result["translation"].presence || result["english"].presence || ""

    if translation.blank? && result["raw_response"].present?
      translation = result["raw_response"].to_s.strip
    end

    render json: { translation: translation.to_s }
  rescue StandardError => e
    Rails.logger.error("[wizard_translate_text] #{e.class}: #{e.message}")
    render json: { error: "Could not translate right now." }, status: :unprocessable_entity
  end

  # Runs arbitrary wizarding instructions and returns the generated output text.
  def apply_instruction
    text = params[:text].to_s.strip
    body = params[:body].to_s
    hint = params[:hint].to_s
    return render json: { error: "text is required" }, status: :unprocessable_entity if text.blank?
    return render json: { error: "text is too long (max 8000 characters)" }, status: :unprocessable_entity if text.length > 8000

    prompt = <<~PROMPT
      Follow the user's instruction exactly and produce the requested output.
      Return ONLY a JSON object with one key:
      - "output": the final generated text result.
      No explanations or extra keys.

      Instruction:
      """
      #{text}
      """

      Additional context:
      - Body: #{body}
      - Hint: #{hint}
    PROMPT

    result = WizardService.ask(prompt, "json_object")
    output = result["output"].presence || result["result"].presence || result["text"].presence || ""
    output = result["raw_response"].to_s.strip if output.blank? && result["raw_response"].present?

    render json: { output: output.to_s }
  rescue StandardError => e
    Rails.logger.error("[wizard_apply_instruction] #{e.class}: #{e.message}")
    render json: { error: "Could not apply instruction right now." }, status: :unprocessable_entity
  end

  # Admin: run the live blockable-set prompt against the model; expect JSON array shape from expected_json.
  def block_set_testing
    prompt = params[:prompt].to_s
    expected_json = params[:expected_json].to_s
    if prompt.blank?
      return render json: { error: "prompt is required" }, status: :unprocessable_entity
    end
    if expected_json.blank?
      return render json: { error: "expected_json is required" }, status: :unprocessable_entity
    end
    if prompt.length > 48_000
      return render json: { error: "prompt is too long (max 48000 characters)" }, status: :unprocessable_entity
    end
    if expected_json.length > 24_000
      return render json: { error: "expected_json is too long (max 24000 characters)" }, status: :unprocessable_entity
    end

    wizard_prompt = <<~PROMPT
      You are testing a "blockable set" configuration for language-processing prompts.

      Return ONLY a JSON object with exactly one top-level key:
      - "items": a JSON array. Each element must be a plain object whose keys match the keys shown in the EXPECTED STRUCTURE sample below (same keys for every row). Fill values with real strings produced by strictly following the INSTRUCTIONS below—do not use the placeholder word "String" unless it is the genuine answer.

      EXPECTED STRUCTURE (array of objects; values are illustrative only):
      #{expected_json}

      INSTRUCTIONS (complete prompt to execute; includes any payload line):
      #{prompt}
    PROMPT

    parsed = WizardService.ask(wizard_prompt.strip, "json_object")
    items = parsed["items"]
    if items.is_a?(Array)
      render json: { ok: true, items: items }
    else
      render json: {
        ok: false,
        parsed: parsed,
        message: "The model did not return a top-level \"items\" array; showing parsed JSON for debugging."
      }
    end
  rescue StandardError => e
    Rails.logger.error("[wizard_block_set_testing] #{e.class}: #{e.message}")
    render json: { error: "Block set test failed. Try again." }, status: :unprocessable_entity
  end

  # Admin: remix a SINGLE field on a SINGLE wizard tile row.
  #
  # body:
  # - context_type: "chapter_layer_item" | "chapter_image_overlay"
  # - context_id: Integer
  # - language_chapter_blockable_set_id: Integer
  # - row_index: Integer
  # - field_key: String
  # - instruction: String (free-form; bolt menu “Manual” mode), OR
  # - language_chapter_blockable_option_bolt_action_id: Integer (preset prompt for that option)
  #
  # returns: { ok: true, value: String, row_index: Integer, field_key: String }
  def block_tile_remix
    context_type = params.require(:context_type).to_s
    context_id = params.require(:context_id)
    set_id = params.require(:language_chapter_blockable_set_id)
    row_index = params.require(:row_index).to_i
    field_key = params.require(:field_key).to_s.strip
    bolt_action_id = params[:language_chapter_blockable_option_bolt_action_id]
    instruction = params[:instruction].to_s.strip

    if field_key.blank?
      return render json: { error: "field_key is required" }, status: :unprocessable_entity
    end

    set = LanguageChapterBlockableSet.find(set_id)

    if bolt_action_id.present?
      action = LanguageChapterBlockableOptionBoltAction.find_by(id: bolt_action_id)
      unless action
        return render json: { error: "Bolt action not found" }, status: :not_found
      end
      option = action.language_chapter_blockable_option
      unless option.language_chapter_blockable_set_id == set.id
        return render json: { error: "Invalid bolt action for this block set" }, status: :unprocessable_entity
      end
      row_keys = set.option_row_keys_by_option_id
      unless row_keys[option.id].to_s == field_key
        return render json: { error: "Bolt action does not match selected field" }, status: :unprocessable_entity
      end
      instruction = action.prompt.to_s.strip
    end

    if instruction.blank?
      return render json: { error: "instruction is required" }, status: :unprocessable_entity
    end
    if instruction.length > 8000
      return render json: { error: "instruction is too long (max 8000 characters)" }, status: :unprocessable_entity
    end

    row_hash, current_value, chapter_language_id =
      BlockTileRemixFetcher.fetch!(
        context_type: context_type,
        context_id: context_id,
        set: set,
        row_index: row_index,
        field_key: field_key
      )

    prompt = BlockTileRemixPromptBuilder.build(
      set: set,
      row_hash: row_hash,
      field_key: field_key,
      current_value: current_value,
      instruction: instruction
    )

    parsed = WizardService.ask(prompt, "json_object")
    value = parsed["value"].presence || parsed["output"].presence || parsed["result"].presence
    value = parsed["raw_response"].to_s.strip if value.blank? && parsed["raw_response"].present?
    value = value.to_s

    render json: { ok: true, value: value, row_index: row_index, field_key: field_key }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not found" }, status: :not_found
  rescue ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue BlockTileRemixFetcher::UserError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("[wizard_block_tile_remix] #{e.class}: #{e.message}")
    render json: { error: "Could not remix block right now." }, status: :unprocessable_entity
  end

  private

  def normalize_result(result)
    extracted = result["original_arabic"].presence || result["arabic"].presence || result["original"].presence
    translation = result["translation"].presence || result["translation_en"].presence || result["english"].presence
    if extracted.blank? && translation.blank? && result["raw_response"].present?
      extracted = result["raw_response"].to_s
    end
    [extracted, translation]
  end

  def parse_text_contract(raw_text)
    text = raw_text.to_s
    arabic = text[/ARABIC:\s*(.+)/i, 1].to_s.strip
    translation = text[/TRANSLATION:\s*(.+)/i, 1].to_s.strip
    [arabic, translation]
  end
end
