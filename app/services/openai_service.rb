# app/services/openai_service.rb
require "openai"
require "json"

class OpenaiService
  attr_reader :client, :prompt

  def initialize(prompt)
    @client = OpenAI::Client.new
    @prompt = prompt
  end

  def call
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "user", content: prompt }], # Required.
        temperature: 0.7,
        stream: false,
        max_tokens: 3200 # keep buffer for prompt tokens
      })

    if response["error"]
      return response
    else
      return response["choices"][0]["message"]["content"]
      # return JSON.parse(response["choices"][0]["message"]["content"])
    end
  end

  def create_picture
    response = client.images.generate(
      parameters: {
        prompt: prompt,
        size: "512x512"
        })
    # return response.dig("data", 0, "url")
    return response["data"][0]["url"]
  end
end
