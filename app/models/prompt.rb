class Prompt < ApplicationRecord
  belongs_to :user
  belongs_to :reference_story, class_name: 'Story', foreign_key: 'reference_story_id', optional: true

  has_one :story

  validates :language, inclusion: { in: %w(English Spanish German French) }
  validates :user_input, presence: true
  validates :age_group, presence: true
  validates :genre, presence: true
end
