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
      return response["error"]["message"]
    else
      return response["choices"][0]["message"]["content"]
      # return JSON.parse(response["choices"][0]["message"]["content"])
    end
  end
end

=begin
# create test response in rails console
prompt = "Please create the following things for me:
- Title for a bedtime story, not longer than 5 words
- Summary of a bedtime story not longer than 5 sentences
- Summary of a bedtime story not longer than one sentence

I would like the answer to be in JSON format, with the following keys: body, title, summary and follow_up_summary.
The title key should contain the title of the story, the summary a one liner summary of the story and the follow_up_summary a paragraph summary of the story. The response should be a JSON and JSON only!
"
response = OpenaiService.new(prompt).call
JSON.parse(response)
=end
