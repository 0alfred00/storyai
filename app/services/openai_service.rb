# app/services/openai_service.rb
require "openai"

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
          temperature: 1.6,
          stream: false,
					max_tokens: 3200 # keep buffer for prompt tokens
      })

    return response["choices"][0]["message"]["content"]
  end
end
# create test response in rails console
#response = OpenaiService.new("You are a world class author for children's books. Help me create a bedtime story to read to my child that is based on the hero's journey. It should be about a one-eyed crocodile tht is looking for water on Mars.").call
