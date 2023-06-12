class StoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    if params[:query].present?
      @stories = Story.search_by_title_and_summary(params[:query])
    else
      @stories = Story.all
    end
  end

  def show
    @story = Story.find(params[:id])
  end

  def history
    prompts = current_user.prompts
    @stories = Story.where(prompt: prompts)
  end

  # def update
  #   @story = Story.find(params[:id])
  #   if @story.public
  #     @story.update(public: false)
  #   else
  #     @story.update(public: true)
  #   end
  # end

  def update
    @story = Story.find(params[:id])
    @story.update(public: !@story.public)
    respond_to do |format|
      format.js
    end
  end

  def create
    # create the final prompt string to be sent to api
    check_prompt_input(params[:user_input], params[:length], params[:language], params[:genre], params[:age_group])
    @prompt = build_prompt(@user_input, @length, @language, @genre, params[:reference_story_id])


    # save prompt data to database
    new_prompt = Prompt.create(language: @language, length: @length, user_input: @user_input, age_group: @age_group, genre: @genre, user_id: current_user.id, reference_story_id: params[:reference_story_id])

    new_prompt.save

    # send prompt to api and receive response
    response_string = OpenaiService.new(@prompt).call
    if response_string["error"]
      flash[:alert] = "Sorry, we couldn't generate a story with the parameters you provided. Please try again."
      redirect_to root_path
    else
      @response = JSON.parse(response_string)

      # create and save story
      new_story = Story.create(title: @response["title"], body: @response["body"], summary: @response["summary"], follow_up_summary: @response["follow_up_summary"], public: true, prompt_id: new_prompt.id)
      new_story.save

      # redirect to story show page
      redirect_to story_path(new_story)
    end
  end

  private

  # this is the prompt with interpolated variables
  # it either runs the initial prompt or the follow up prompt based on whether there is a reference story
  def build_prompt(user_input, length, language, genre, reference_story_id)
    if reference_story_id
      follow_up_summary = Story.find(reference_story_id).follow_up_summary
      "You are a world class author for children's bedtime stories. You will create a sequel bedtime story that adheres to the best practices of storytelling and following the hero’s journey while being appropriate for children. The story is later read by parents to their children before they go to bed.
      I will give you a summary of the previous story to base your sequel on, additional content instructions, story parameters and restrictions that should control the content of the bedtime story you are creating.

      Summary of previous story:
      - #{follow_up_summary}

      Content instruction
      - #{user_input}

      Parameters:
      - Length should be around #{length} words but must not be longer than #{length.to_i + 100} words.
      - Language of the story is #{language}
      - Genre is #{genre}

      Restrictions:
      - The story has to be suited for children and must not contain inappropriate content like violence, drugs, murder, sex, nudity and swearing

      Now please create the sequel bedtime story based on the summary, content instruction, story parameters and restrictions given above. After you have created the bedtime story, please also create the following:
      - Title for the bedtime story, not longer than 5 words in #{language}
      - Summary of the bedtime story not longer than 5 sentences and not less than 4 sentences in English
      - Summary of the bedtime story not longer than one sentence in #{language}
      I would like the answer to be in JSON format, with the following keys: body, title, summary and follow_up_summary.

      The body key should contain the whole content of the story, the title the title of the story, the summary a one liner summary of the story and the follow_up_summary a paragraph summary of the story. The response should be a json and json only!
      "
    else
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

  # check what the user is prompting, if they forgot to fill out all form fields
  # default data is applied
  def check_prompt_input(user_input, length, language, genre, age_group)
    @user_input = user_input.presence || "bird and cat become friends"
    @length = length.presence || "500"
    @language = (language == "Language") ? "English" : language
    @genre = (genre == "Genre") ? "Fairytale" : genre
    @age_group = (age_group == "Age Group") ? "Toddler" : age_group
  end


  def story_params
    params.require(:story).permit(:public)
  end
end
