class Rating < ActiveRecord::Base
  validates_presence_of :value
  validates :user_id, :uniqueness => { :scope => :movie_id }
  validates_presence_of :user_id
  validates_presence_of :movie

  belongs_to :user
  belongs_to :movie

  enum value: { "10 stars": 10, "9 stars": 9, "8 stars": 8, "7 stars": 7,
    "6 stars": 6, "5 stars": 5, "4 stars": 4, "3 stars": 3, "2 stars": 2, "1 star": 1 }

  scope :by_user, lambda { |user| where(:user_id => user.id) }

end
