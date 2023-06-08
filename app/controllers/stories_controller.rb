class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    @stories = Story.all
    
  end

  def create
    # create the final prompt to be sent to api
    @prompt = build_prompt(params[:user_input], params[:length], params[:language], params[:genre])

    # checking if there is a story to reference
    reference_story_id = params[:story_id].present? ? params[:story_id] : nil

    # create prompt
    new_prompt = Prompt.create(language: params[:language], length: params[:length], user_input: params[:user_input], age_group: params[:age_group], genre: params[:genre], user_id: current_user.id, reference_story_id: reference_story_id)
    new_prompt.save

    # send prompt to api and receive response
    response_string = OpenaiService.new(@prompt).call
    @response = JSON.parse(response_string)

    # create story
    new_story = Story.create(title: @response["title"], body: @response["body"], summary: @response["summary"], follow_up_summary: @response["follow_up_summary"], public: true, prompt_id: new_prompt.id)
    new_story.save

    # redirect to story show page
    redirect_to story_path(new_story)
  end

  def build_prompt(user_input, length, language, genre)

    # this is the prompt with interpolated variables
    "You are a world class author for children's bedtime stories. You will create a bedtime story that adheres to the best practices of storytelling and following the hero’s journey while being appropriate for children. The story is later read by parents to their children before they go to bed.
    I will give you a content instruction, story parameters and restrictions that should control the content of the bedtime story you are creating.

    Content instruction
    - #{user_input}

    Parameters:
    - Length should be around #{length} words but must not be longer than #{length.to_i + 100} words.
    - Language of the story is #{language}
    - Genre is #{genre}

    Restrictions:
    - The story has to be suited for children and must not contain inappropriate content like violence, drugs, murder, sex, nudity and swearing

    Now please create the bedtime story based on the instructions, content instruction, story parameters and restrictions given above. After you have created the bedtime story, please also create the following. Start a new paragraph for each item:
    - Title for the bedtime story, not longer than 5 words in #{language}
    - Summary of the bedtime story not longer than 5 sentences in English
    - Summary of the bedtime story not longer than one sentence in #{language}
    I would like the answer to be in JSON format, with the following keys: body, title, summary and follow_up_summary.

    The body key should contain the whole content of the story, the title the title of the story, the summary a one liner summary of the story and the follow_up_summary a paragraph summary of the story. The response should be a json and json only!
     "
  end
end
