class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :story

  validates :rating, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :story_id, message: "You can only rate a story once." }
end
