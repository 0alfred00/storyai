# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require "faker"

# Seed Users
10.times do
  User.create!(
    email: Faker::Internet.email,
    # encrypted_password: Faker::Internet.password(min_length: 8),
    password: Faker::Internet.password(min_length: 8)
    # created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
  )
end

# Seed Stories
users = User.all
users.each do |user|
  3.times do
    prompt = Prompt.create!(
      language: "German",
      length: rand(250..500),
      user_input: Faker::Lorem.sentence(word_count: 10),
      age_group: ["Babies", "Toddler", "Ages 5-8", "Ages 9-12"].sample
      genre: ["Babies", "Toddler", "Ages 5-8", "Ages 9-12"].sample,
      user_id: user.id,
      created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
    )

    story = Story.create!(
      title: Faker::Lorem.sentence(word_count: 4),
      body: Faker::Lorem.paragraph(sentence_count: 10),
      summary: Faker::Lorem.sentence(word_count: 8),
      public: [true, false].sample,
      follow_up_summary: Faker::Lorem.sentence(word_count: 15),
      prompt_id: prompt.id,
      created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
    )

    5.times do
      story.favorites.create!(
        user_id: users.sample.id,
        created_at: Faker::Time.between(from: DateTime.now - 1, to: DateTime.now)
      )
    end
  end
end

puts "#{User.count} users created"
puts "#{Prompt.count} prompts created"
puts "#{Story.count} stories created"
puts "#{Favorite.count} favorites created"
puts "Seed data generated successfully! Yeah!"
