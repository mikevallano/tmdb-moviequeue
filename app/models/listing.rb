class Listing < ActiveRecord::Base
  belongs_to :list
  belongs_to :movie

  validates_presence_of :list
  validates_presence_of :movie
end
