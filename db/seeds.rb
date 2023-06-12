# /db/seeds.rb
# seed data for development and testing

# require "faker"

# # Seed Users
# 10.times do
#   User.create!(
#     email: Faker::Internet.email,
#     # encrypted_password: Faker::Internet.password(min_length: 8),
#     password: Faker::Internet.password(min_length: 8)
#     # created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
#   )
# end

# # # Seed Stories

# users = User.all
# age_groups = ["Babies", "Toddler", "Ages 5-8", "Ages 9-12"]
# genres = ["Educational", "Adventurous", "Mystery", "Fairytale"]
# users.each do |user|
#   3.times do
#     prompt = Prompt.create!(
#       language: "German",
#       length: rand(250..500),
#       user_input: Faker::Lorem.sentence(word_count: 10),
#       age_group: age_groups.sample,
#       genre: genres.sample,
#       user_id: user.id,
#       created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
#     )

#     story = Story.create!(
#       title: Faker::Lorem.sentence(word_count: 4),
#       body: Faker::Lorem.paragraph(sentence_count: 10),
#       summary: Faker::Lorem.sentence(word_count: 8),
#       public: [true, false].sample,
#       follow_up_summary: Faker::Lorem.sentence(word_count: 15),
#       prompt_id: prompt.id,
#       created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
#     )

#     rand(0..5).times do
#       story.favorites.create!(
#         user_id: users.sample.id,
#         created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
#       )
#     end
#   end
# end

# # @stories = Story.all
# # @stories.each do |story|
# #   rand(54..517).times do
# #     story.favorites.create!(
# #       user_id: users.sample.id
# #     )
# #   end
# # end

# puts "#{User.count} users created"
# puts "#{Prompt.count} prompts created"
# puts "#{Story.count} stories created"
# puts "#{Favorite.count} favorites created"
# puts "Seed data generated successfully! Yeah!"

# # # Seed Stories
# users = User.all
# # age_groups = ["Babies", "Toddler", "Ages 5-8", "Ages 9-12"]
# # genres = ["Educational", "Adventurous", "Mystery", "Fairytale"]
# # users.each do |user|
# #   3.times do
# #     prompt = Prompt.create!(
# #       language: "German",
# #       length: rand(250..500),
# #       user_input: Faker::Lorem.sentence(word_count: 10),
# #       age_group: age_groups.sample,
# #       genre: genres.sample,
# #       user_id: user.id,
# #       created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
# #     )

# #     story = Story.create!(
# #       title: Faker::Lorem.sentence(word_count: 4),
# #       body: Faker::Lorem.paragraph(sentence_count: 10),
# #       summary: Faker::Lorem.sentence(word_count: 8),
# #       public: [true, false].sample,
# #       follow_up_summary: Faker::Lorem.sentence(word_count: 15),
# #       prompt_id: prompt.id,
# #       created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
# #     )

# #     # rand(0..100).times do
# #     #   story.favorites.create!(
# #     #     user_id: users.sample.id,
# #     #     created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
# #     #   )
# #     # end
# #   end
# # end

# @stories = Story.all
# @stories.each do |story|
#   rand(54..517).times do
#     story.favorites.create!(
#       user_id: users.sample.id
#     )
#   end
# end

# puts "#{User.count} users created"
# puts "#{Prompt.count} prompts created"
# puts "#{Story.count} stories created"
# puts "#{Favorite.count} favorites created"
# puts "Seed data generated successfully! Yeah!"


# heroku seed please do not run the code below it costs 5€ on openai API each time

# Replace with your own Cloudinary credentials
CLOUDINARY_CLOUD_NAME = 'dwszg7wzr'
CLOUDINARY_API_KEY = '364941357431972'
CLOUDINARY_API_SECRET = 'ZzgPSnVgq8m2ByBW10s5cB3MRYA'

require 'cloudinary'
require 'openai'
require 'faker'

# Set up Cloudinary client
Cloudinary.config do |config|
  config.cloud_name = CLOUDINARY_CLOUD_NAME
  config.api_key = CLOUDINARY_API_KEY
  config.api_secret = CLOUDINARY_API_SECRET
end

# Create users
users = []
5.times do |i|
  user = User.create!(email: "user#{i + 1}@example.com", password: '123456')
  users << user
end

# Create prompts and stories

age_groups = ["Babies", "Toddler", "Ages 5-8", "Ages 9-12"]
genres = ["Educational", "Adventurous", "Mystery", "Fairytale"]

users.each do |user|
  3.times do |j|
    prompt = Prompt.create(
      language: 'English',
      length: 400,
      user_input: "Write a children's bedtime story about #{Faker::Creature::Animal.name}.",
      age_group: age_groups.sample,
      genre: genres.sample,
      user_id: user.id
    )

    # Generate story using OpenAI API
    # create prompt
    prompt_sent = "You are a world class author for children's bedtime stories. You will create a bedtime story that adheres to the best practices of storytelling and following the hero’s journey while being appropriate for children. The story is later read by parents to their children before they go to bed.
    I will give you a content instruction, story parameters and restrictions that should control the content of the bedtime story you are creating.

    Content instruction
    - #{prompt[:user_input]}

    Parameters:
    - Length should be around #{prompt[:length]} words but must not be longer than #{prompt[:length].to_i + 100} words.
    - Language of the story is #{prompt[:language]}
    - Genre is #{prompt[:genre]}

    Restrictions:
    - The story has to be suited for children and must not contain inappropriate content like violence, drugs, murder, sex, nudity and swearing.
    Now please create the bedtime story based on the instructions, content instruction, story parameters and restrictions given above. After you have created the bedtime story, please also create the following. Start a new paragraph for each item:
    - Title for the bedtime story, not longer than 5 words in #{prompt[:language]}
    - Summary of the bedtime story not longer than 5 sentences in English
    - Summary of the bedtime story not longer than one short sentence in #{prompt[:language]}
    I would like the answer to be in JSON format, with the following keys: body, title, summary and follow_up_summary.

    The body key should contain the whole content of the story, the title the title of the story, the summary a one liner summary of the story and the follow_up_summary a paragraph summary of the story. The response should be a json and json only!
    "

    response = OpenaiService.new(prompt_sent).call
    new_story = JSON.parse(response)

    # Generate story picture using OpenAI API
    picture_prompt = "Create a cover photo for a children's bedtime story. The style should be fantasy and based on the following summary: #{new_story["summary"]}"
    picture_url = OpenaiService.new(picture_prompt).create_picture

    # Upload picture to Cloudinary
    uploaded_picture = Cloudinary::Uploader.upload(picture_url)

    # Create story
    story = Story.create(
      title: new_story["title"],
      body: new_story["body"],
      summary: new_story["summary"],
      public: true,
      follow_up_summary: new_story["follow_up_summary"],
      prompt_id: prompt.id
    )
    # new_story.save!

    # Attach picture to story
    story.photo.attach(
      io: URI.open(uploaded_picture['secure_url']),
      filename: 'story_picture.png',
      content_type: 'image/png'
    )
    story.save!
  end

  # Create favorites for random stories
  rand(3..Story.count).times do
    Favorite.create(user_id: user.id, story_id: Story.all.sample.id)
  end
end

puts "Seeds created successfully!"
puts "Users count: #{User.count}"
puts "Prompts count: #{Prompt.count}"
puts "Stories count: #{Story.count}"
puts "Favorites count: #{Favorite.count}"
