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

    response_format == "json_object" ? JSON.parse(raw_content) : raw_content
  end
end
