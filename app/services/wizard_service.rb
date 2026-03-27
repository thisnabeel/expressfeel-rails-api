class WizardService
  def self.ask(prompt, response_format = "json_object")
    client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])

    puts "The prompt: #{prompt}"

    content = prompt.dup
    case response_format
    when "json_object"
      content += ". Your response should be in JSON format."
    when "text"
      content += "\n\nRespond **only** in valid GitHub-flavored Markdown."
    end

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: content }],
        temperature: 0.7,
        response_format: { type: response_format }
      }
    )

    raw_content = response.dig("choices", 0, "message", "content").to_s.lstrip
    puts raw_content

    response_format == "json_object" ? parse_json_response(raw_content) : raw_content
  end

  def self.ask_with_image(prompt:, image_base64:, image_mime_type: "image/png", response_format: "json_object")
    client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])

    content = prompt.dup
    case response_format
    when "json_object"
      content += ". Your response should be in JSON format."
    when "text"
      content += "\n\nRespond **only** in valid GitHub-flavored Markdown."
    end

    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: content },
              {
                type: "image_url",
                image_url: {
                  url: "data:#{image_mime_type};base64,#{image_base64}"
                }
              }
            ]
          }
        ],
        temperature: 0.2,
        response_format: { type: response_format }
      }
    )

    raw_content = response.dig("choices", 0, "message", "content").to_s.lstrip
    response_format == "json_object" ? parse_json_response(raw_content) : raw_content
  end

  def self.parse_json_response(raw_content)
    return {} if raw_content.blank?

    JSON.parse(raw_content)
  rescue JSON::ParserError
    cleaned = raw_content.to_s.strip
    cleaned = cleaned.gsub(/\A```(?:json)?\s*/i, "").gsub(/\s*```\z/, "")

    begin
      return JSON.parse(cleaned)
    rescue JSON::ParserError
      # Try to recover first JSON object if extra tokens/fences are present.
      start_idx = cleaned.index("{")
      end_idx = cleaned.rindex("}")
      if start_idx && end_idx && end_idx > start_idx
        candidate = cleaned[start_idx..end_idx]
        begin
          return JSON.parse(candidate)
        rescue JSON::ParserError
          # fall through
        end
      end
    end

    { "raw_response" => cleaned }
  end
end
