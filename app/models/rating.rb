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

  def value_text
    v = value
    case v
    when 1
      "1 Star"
    when 2
      "2 Stars"
    when 3
      "3 Stars"
    when 4
      "4 Stars"
    when 5
      "5 Stars"
    when 6
      "6 Stars"
    when 7
      "7 Stars"
    when 8
      "8 Stars"
    when 9
      "9 Stars"
    when 10
      "10 Stars"
    end
  end #value text

end
