class Listing < ActiveRecord::Base
  belongs_to :list
  belongs_to :movie

  validates_presence_of :list
  validates_presence_of :movie

  enum priority: { top: 5, high: 4, medium: 3, low: 2, bottom: 1 }
end
