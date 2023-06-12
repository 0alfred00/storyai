class Story < ApplicationRecord
  belongs_to :prompt

  has_many :favorites
  has_many :users, through: :favorites

  has_one_attached :photo
end
