class Movie < ActiveRecord::Base

  validates_presence_of :tmdb_id
  validates_uniqueness_of :tmdb_id
end
