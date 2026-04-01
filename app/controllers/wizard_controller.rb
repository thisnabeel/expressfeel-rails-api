class WizardController < ApplicationController
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
