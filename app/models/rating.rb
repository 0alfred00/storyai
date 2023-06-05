class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :story

  validates :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }
end
