class Prompt < ApplicationRecord
  belongs_to :user
  has_one :story

  validates :language, inclusion: { in: %w(English Spanish German French) }
  validates :user_input, presence: true
  validates :age_group, presence: true
  validates :genre, presence: true
end
