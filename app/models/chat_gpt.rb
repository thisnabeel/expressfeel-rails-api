class ChatGPT < ActiveRecord::Base
    def self.send(prompt)
        client = OpenAI::Client.new
        puts "The prompt: #{prompt}"
        content = "#{prompt}. Your response should be in JSON format."
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo", # Required.
                messages: [{ role: "user", content: content}], # Required.
                temperature: 0.7,
            })

        # return response.dig("choices", 0, "message", "content")
        jsonResponse = JSON.parse(response.dig("choices", 0, "message", "content").lstrip)
        return jsonResponse

    end
end
