class StoriesWorker
  include Sidekiq::Worker

  def perform(prompt_id)
    # find the prompt by id
    prompt = Prompt.find(prompt_id)
    api_prompt = build_api_prompt(prompt["user_input"], prompt["length"], prompt["language"], prompt["genre"], prompt["reference_story_id"], prompt["age_group"])

    # send prompt to api and receive response
    response_string = OpenaiService.new(api_prompt).call
    if response_string["error"]
      flash[:alert] = "Sorry, we couldn't generate a story with the parameters you provided. Please try again."
      redirect_to root_path
    else
      response = JSON.parse(response_string)

      # create and save story
      new_story = Story.create(title: response["title"], body: response["body"], summary: response["summary"], follow_up_summary: response["follow_up_summary"], public: true, prompt_id: prompt.id)
      new_story.save

      # broadcast to ActionCable
      ActionCable.server.broadcast("story", { story_id: new_story.id })

      # create and save picture
      # create_and_save_picture(new_story)
      create_and_save_picture(prompt)

      # redirect to story show page
      # redirect_to story_path(new_story)
      # generate a URL for the new story
      # story_url = Rails.application.routes.url_helpers.story_url(new_story, host: 'localhost:3000')
    end
  end

  private

    # this is the prompt with interpolated variables
  # it either runs the initial prompt or the follow up prompt based on whether there is a reference story
  def build_api_prompt(user_input, length, language, genre, reference_story_id, age_group)
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
      - Appropriate for children in the age group #{age_group}

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
      - Appropriate for children in the age group #{age_group}

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

  # def create_and_save_picture(story)
  #   prompt_picture = build_api_prompt_picture(story.follow_up_summary)
  #   picture_url = OpenaiService.new(prompt_picture).create_picture
  #   story.photo.attach(io: URI.open(picture_url), filename: 'story_picture.png', content_type: 'image/png')
  #   story.save
  # end

  def create_and_save_picture(prompt)
    prompt_picture = build_api_prompt_picture(prompt.user_input)
    picture_url = OpenaiService.new(prompt_picture).create_picture
    prompt.story.photo.attach(io: URI.open(picture_url), filename: 'story_picture.png', content_type: 'image/png')
    prompt.story.save
  end

  def build_api_prompt_picture(prompt)
    default = "Create a cover photo for a children's bedtime story. The style should be fantasy and based on the following summary: "
    default + prompt
  end
end
