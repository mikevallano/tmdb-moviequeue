class Movie < ActiveRecord::Base

  self.per_page = 20

  extend FriendlyId
  friendly_id :title, :use => :history

  validates_presence_of :tmdb_id
  validates_uniqueness_of :tmdb_id

  has_many :listings
  has_many :lists, through: :listings

  has_many :taggings
  has_many :tags, through: :taggings

  has_many :reviews

  has_many :ratings

  has_many :screenings

  def times_seen_by(user)
    Screening.where(user_id: user.id, movie_id: self.id).count
  end

  def self.by_user(user)
    joins(:lists).where(lists: { owner_id: user.id }).uniq
  end

  def self.tagged_with(tag_name, userlist)
    Tag.by_user_or_list(userlist).find_by_name!(tag_name).movies.uniq
  end

  def tag_list(userlist)
    tags.by_user_or_list(userlist).map
  end

  def self.by_genre(genre)
    Movie.where("genres && ARRAY[?]::varchar[]", genre)
  end

  def priority(list)
    listings.find_by(list_id: list.id).priority
  end

  GENRES = [["Action", 28], ["Adventure", 12], ["Animation", 16], ["Comedy", 35], ["Crime", 80],
  ["Documentary", 99], ["Drama", 18], ["Family", 10751], ["Fantasy", 14], ["Foreign", 10769], ["History", 36],
  ["Horror", 27], ["Music", 10402], ["Mystery", 9648], ["Romance", 10749], ["Science Fiction", 878], ["TV Movie", 10770],
  ["Thriller", 53], ["War", 10752], ["Western", 37]]

  MPAA_RATINGS = [ ["R", "R"], ["NC-17", "NC-17"], ["PG-13", "PG-13"], ["G", "G"] ]

  SORT_BY = [ ["Popularity", "popularity"], ["Release date", "release_date"], ["Revenue", "revenue"],
  ["Vote average", "vote_average"], ["Vote count","vote_count"] ]

  YEAR_SELECT = [ ["Exact Year", "exact"], ["After This Year", "after"], ["Before This Year", "before"] ]

end
