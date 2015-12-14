class Screening < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :movie

  belongs_to :user
  belongs_to :movie

  scope :by_user, lambda { |user| where(:user_id => user.id) }
end

