class WizardService
    def self.ask(prompt)
        
        client = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
        puts client
        puts client.as_json

        puts "The prompt: #{prompt}"
        content = "#{prompt}. Your response should be in JSON format."
        response = client.chat(
            parameters: {
                model: "gpt-4o", # Required.
                messages: [{ role: "user", content: content}], # Required.
                temperature: 0.7,
                response_format: { type: "json_object" }
            })

        # return response.dig("choices", 0, "message", "content")
        puts response.dig("choices", 0, "message", "content")
        jsonResponse = JSON.parse(response.dig("choices", 0, "message", "content").lstrip)
        return jsonResponse

    end
end
