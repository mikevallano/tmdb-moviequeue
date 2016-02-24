class Rating < ActiveRecord::Base
  validates_presence_of :value
  validates :user_id, :uniqueness => { :scope => :movie_id }
  validates_presence_of :user_id
  validates_presence_of :movie

  belongs_to :user
  belongs_to :movie

  VALUES = [ ["10", 10], ["9", 9], ["8", 8], ["7", 7],
    ["6", 6], ["5", 5], ["4", 4], ["3", 3], ["2", 2], ["1", 1] ]

  scope :by_user, lambda { |user| where(:user_id => user.id) }

end
