class StoriesWorker
  include Sidekiq::Worker

  def perform(prompt_id)
    # Find the prompt by id and build final api_prompt
    prompt = Prompt.find(prompt_id)
    api_prompt = build_api_prompt(
      prompt["user_input"],
      prompt["length"],
      prompt["language"],
      prompt["genre"],
      prompt["reference_story_id"],
      prompt["age_group"]
    )

    # Send prompt to api and receive response
    response_string = OpenaiService.new(api_prompt).call
    if response_string["error"]
      flash[:alert] = "Sorry, we couldn't generate a story with the parameters you provided. Please try again."
      redirect_to root_path
    else
      # Save story to database
      response = JSON.parse(response_string)
      new_story = Story.create(
        title: response["title"],
        body: response["body"],
        summary: response["summary"],
        follow_up_summary: response["follow_up_summary"],
        public: true,
        prompt_id: prompt.id
      )
      new_story.save

      # Create picture
      create_and_save_picture(prompt)
    end
  end

  private

  # This is the prompt with interpolated variables
  # It either runs the initial prompt or the follow up prompt based on whether there is a reference story
  def build_api_prompt(user_input, length, language, genre, reference_story_id, age_group)
    if reference_story_id
      follow_up_summary = Story.find(reference_story_id).follow_up_summary
      "PERSONA:
      You are a world class author for children's bedtime stories. You will create a sequel bedtime story that adheres to the best practices of storytelling and following the hero’s journey while being appropriate for children. The story is later read by parents to their children before they go to bed.
      I will give you a summary of the previous story to base your sequel on, additional content instructions, story parameters and restrictions that should control the content of the bedtime story you are creating.

      #####
      INPUT:
      Summary of previous story:
      - #{follow_up_summary}

      Content instruction
      - #{user_input}

      Parameters:
      - The bedtime story MUST be at least #{length} words but must not be longer than #{length.to_i + 200} words.
      - Language of the story is #{language}
      - Genre is #{genre}
      - Appropriate for children in the age group #{age_group}

      Restrictions:
      - The story MUST be suited for children and MUST NOT contain inappropriate content like violence, drugs, murder, sex, nudity and swearing

      #####
      TASK:
      Now please create the sequel bedtime story based on the summary, content instruction, story parameters and restrictions given above. After you have created the bedtime story, please also create the following:
      - Title for the bedtime story, not longer than 5 words in #{language}
      - Follow Up Summary of the bedtime story not longer than 5 sentences and not less than 4 sentences in English
      - Summary of the bedtime story not longer than one short sentence and it MUST be in #{language}

      #####
      OUTPUT FORMAT:
      I would like the answer to be in JSON format, with the following keys: body, title, follow_up_summary and summary.
      The body is the bedtime story, the title is the Title from above, the follow_up_summary is the Follow Up Summary in English from above, the summary is the Summary in #{language} from above.
      The response should be a json and json only!
      "
    else
      "PERSONA:
      You are a world class author for children's bedtime stories. You will create a bedtime story that adheres to the best practices of storytelling and following the hero’s journey while being appropriate for children. The story is later read by parents to their children before they go to bed.
      I will give you a content instruction, story parameters and restrictions that should control the content of the bedtime story you are creating.

      #####
      INPUT:
      Content instruction
      - #{user_input}

      Parameters:
      - The bedtime story MUST be at least #{length} words but must not be longer than #{length.to_i + 200} words.
      - Language of the story is #{language}
      - Genre is #{genre}
      - Appropriate for children in the age group #{age_group}

      Restrictions:
      - The story MUST be suited for children and MUST NOT contain inappropriate content like violence, drugs, murder, sex, nudity and swearing

      #####
      TASK:
      Now please create the bedtime story based on the instructions, content instruction, story parameters and restrictions given above. After you have created the bedtime story, please also create the following:
      - Title for the bedtime story, not longer than 5 words in #{language}
      - Follow Up Summary of the bedtime story not longer than 5 sentences in English
      - Summary of the bedtime story not longer than one short sentence and it MUST be in #{language}

      #####
      OUTPUT FORMAT:
      I would like the answer to be in JSON format, with the following keys: body, title, follow_up_summary and summary.
      The body is the bedtime story, the title is the Title from above, the follow_up_summary is the Follow Up Summary in English from above, the summary is the Summary in #{language} from above.
      The response should be a json and json only!
      "
    end
  end

  def create_and_save_picture(prompt)
    prompt_picture = build_api_prompt_picture(prompt.user_input)
    picture_url = OpenaiService.new(prompt_picture).create_picture
    prompt.story.photo.attach(io: URI.open(picture_url), filename: 'story_picture.png', content_type: 'image/png')
    prompt.story.save
  end

  def build_api_prompt_picture(prompt)
    default = "Create a cover photo for a children's bedtime story. The style should be fantasy, colorful and based on the following summary: "
    default + prompt
  end
end
