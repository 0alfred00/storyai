class Story < ApplicationRecord
  belongs_to :prompt
  has_many :ratings
  has_many :favorites
  has_many :users, through: :favorites
  has_many :users, through: :ratings
  has_many :users, through: :prompts

  validates :title, presence: true
  validates :body, presence: true
  validates :summary, presence: true
  validates :follow_up_summary, presence: true

  after_initialize :set_defaults

  private

  def set_defaults
    self.public ||= false
  end
end
