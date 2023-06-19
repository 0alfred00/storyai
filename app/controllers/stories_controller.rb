class StoriesController < ApplicationController
  before_action :set_search, only: [:index]

  def index
    @last_story = Story.last
    # Checks if the user entered a search query in the search bar and displays stories accordingly
    if params[:query].present?
      @search = true
      @stories = Story.search_by_title_and_summary(params[:query])
    else
      @stories = Story.all
    end
  end

  def check_story
    # Endpoint to check if the new story has been created
    # While loading animation is running this endpoint is fetched every second until story is created
    # When true, loading animation is stopped and card links to new story
    story_created = Story.last.prompt == Prompt.last
    render json: { storyCreated: story_created, storyId: Story.last.id }
  end

  def show
    # Shows a story
    @story = Story.find(params[:id])
    # Shows the reference story (aka previous chapter) if there is one
    @reference_story = @story.prompt.reference_story if @story.prompt.reference_story
  end

  def history
    # Indexes all stories current user created
    prompts = current_user.prompts
    @stories = Story.where(prompt: prompts)
  end

  def update
    # Toggle if a story is public or private
    @story = Story.find(params[:id])
    @story.update(public: !@story.public)
    redirect_to request.referrer
  end

  def create
    # Create the final prompt string to be sent to OpenAI API
    # Check form input and replace with defaults if missing
    check_prompt_input(
      params[:user_input],
      params[:length],
      params[:language],
      params[:genre],
      params[:age_group]
    )
    # Save prompt data to database
    new_prompt = Prompt.create(
      language: @language,
      length: @length,
      user_input: @user_input,
      age_group: @age_group,
      genre: @genre,
      user_id: current_user.id,
      reference_story_id: params[:reference_story_id]
    )
    new_prompt.save
    # Offload the work of sending the prompt to the API and processing the response to a background job
    StoriesWorker.perform_async(new_prompt.id)
  end

  private

  def check_prompt_input(user_input, length, language, genre, age_group)
    # Check form input by user
    # Default data is applied if input missing
    @user_input = user_input.presence || "bird and cat become friends"
    @length = length.presence || "800"
    @language = language == "Language" ? "English" : language
    @genre = genre == "Genre" ? "Fairytale" : genre
    @age_group = age_group == "Age Group" ? "Toddler" : age_group
  end

  def set_search
    @search = false
  end
end
