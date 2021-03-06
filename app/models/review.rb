class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :movie

  validates :user_id, :uniqueness => { :scope => :movie_id }, :presence => true
  validates_presence_of :movie
  validates_presence_of :body

  scope :by_user, lambda { |user| where(:user_id => user.id) }
end
