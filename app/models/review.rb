class Review < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :user_id, uniqueness: { scope: :movie_id }, presence: true
  validates_presence_of :movie
  validates_presence_of :body

  scope :by_user, -> (user) { where(user_id: user.id) }
end
