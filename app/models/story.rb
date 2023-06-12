class Story < ApplicationRecord
  belongs_to :prompt

  has_many :favorites
  has_many :users, through: :favorites
  has_one_attached :photo

  include PgSearch::Model
  pg_search_scope :search_by_title_and_summary,
    against: [ :title, :summary ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }
end
