class StoriesController < ApplicationController
  # skip_before_action :authenticate_user!, only: :index
  before_action :set_loading

  def index
    @last_story = Story.last
    if params[:query].present?
      @stories = Story.search_by_title_and_summary(params[:query])
    else
      @stories = Story.all
    end
  end

  def check_story
    # Check if the new story has been created
    story_created = Story.last.prompt == Prompt.last
    render json: { storyCreated: story_created, storyId: Story.last.id }
  end

  def show
    @story = Story.find(params[:id])
    @reference_story = @story.prompt.reference_story if @story.prompt.reference_story
  end

  def history
    prompts = current_user.prompts
    @stories = Story.where(prompt: prompts)
  end

  def update
    @story = Story.find(params[:id])
    @story.update(public: !@story.public)
    respond_to do |format|
      format.js
    end
  end

  def create
    @loading = true
    # create the final prompt string to be sent to api
    check_prompt_input(params[:user_input], params[:length], params[:language], params[:genre], params[:age_group])
    # api_prompt = build_api_prompt(@user_input, @length, @language, @genre, params[:reference_story_id], @age_group)

    # save prompt data to database
    new_prompt = Prompt.create(language: @language, length: @length, user_input: @user_input, age_group: @age_group, genre: @genre, user_id: current_user.id, reference_story_id: params[:reference_story_id])
    new_prompt.save

    # offload the work of sending the prompt to the API and processing the response to a background job
    StoriesWorker.perform_async(new_prompt.id)

    # redirect to a page that informs the user that their story is being generated
    # respond_to do |format|
    #   format.html { redirect_to stories_path }
    #   format.js
    # end
  end



  private

  # check what the user is prompting, if they forgot to fill out all form fields
  # default data is applied
  def check_prompt_input(user_input, length, language, genre, age_group)
    @user_input = user_input.presence || "bird and cat become friends"
    @length = length.presence || "800"
    @language = (language == "Language") ? "English" : language
    @genre = (genre == "Genre") ? "Fairytale" : genre
    @age_group = (age_group == "Age Group") ? "Toddler" : age_group
  end

  def story_params
    params.require(:story).permit(:public)
  end

  def set_loading
    @loading = false
  end
end
