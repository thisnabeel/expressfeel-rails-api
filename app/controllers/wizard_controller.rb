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

    original_arabic, translation = normalize_result(result)

    # Retry with plain-text contract if JSON mode omitted expected fields.
    if original_arabic.blank? || translation.blank?
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
      original_arabic = original_arabic.presence || text_arabic
      translation = translation.presence || text_translation
    end

    if original_arabic.blank?
      original_arabic = "No Arabic text extracted."
    end
    if translation.blank?
      translation = "No translation returned."
    end

    render json: {
      original_arabic: original_arabic.to_s,
      translation: translation.to_s
    }
  rescue StandardError => e
    Rails.logger.error("[wizard_extract_manga_text] #{e.class}: #{e.message}")
    render json: { error: "Could not extract text right now." }, status: :unprocessable_entity
  end

  private

  def normalize_result(result)
    original_arabic = result["original_arabic"].presence || result["arabic"].presence || result["original"].presence
    translation = result["translation"].presence || result["translation_en"].presence || result["english"].presence
    if original_arabic.blank? && translation.blank? && result["raw_response"].present?
      original_arabic = result["raw_response"].to_s
    end
    [original_arabic, translation]
  end

  def parse_text_contract(raw_text)
    text = raw_text.to_s
    arabic = text[/ARABIC:\s*(.+)/i, 1].to_s.strip
    translation = text[/TRANSLATION:\s*(.+)/i, 1].to_s.strip
    [arabic, translation]
  end
end
