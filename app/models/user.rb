class User < ApplicationRecord
  has_many :prompts
  has_many :favorites

  has_many :stories, through: :prompts
  has_many :stories, through: :favorites

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
