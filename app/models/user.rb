class User < ApplicationRecord
  has_many :prompts
  has_many :ratings
  has_many :favorites
  has_many :stories, through: :prompts
  has_many :stories, through: :ratings
  has_many :stories, through: :favorites
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
