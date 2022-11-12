class Listing < ApplicationRecord
  belongs_to :list
  belongs_to :movie
  belongs_to :user

  validates :movie, :uniqueness => { :scope => :list }, :presence => true
  validates_presence_of :list
  validates_presence_of :user

  PRIORITIES = [ ["Top", 5], ["High", 4], ["Normal", 3], ["Low", 2], ["Bottom", 1] ]

  before_save :default_priority

  def default_priority
    self.priority ||= 3
  end
end
