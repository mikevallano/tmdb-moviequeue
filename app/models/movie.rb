# frozen_string_literal: true

class Movie < ActiveRecord::Base
  self.per_page = 20

  extend FriendlyId
  friendly_id :title, :use => :history

  validates :tmdb_id, :uniqueness => :true, :presence => true

  has_many :listings
  has_many :lists, through: :listings
  has_many :users, through: :listings
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :reviews
  has_many :ratings
  has_many :screenings
  has_many :viewers, :through => :screenings,
  :source => :user

  attr_accessor :production_companies

  LIST_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["recently added to list", "recently added to list"],
  ["watched movies", "watched movies"], ["unwatched movies", "unwatched movies"],
  ["recently watched", "recently watched"], ["highest priority", "highest priority"],
  ["only show unwatched", "only show unwatched"], ["only show watched", "only show watched"] ]

  MY_MOVIES_SORT_OPTIONS = [ ["title", "title"], ["shortest runtime", "shortest runtime"],
  ["longest runtime", "longest runtime"], ["newest release", "newest release"],
  ["vote average", "vote average"], ["watched movies", "watched movies"], ["recently watched", "recently watched"],
  ["unwatched movies", "unwatched movies"], ["only show unwatched", "only show unwatched"],
  ["only show watched", "only show watched"], ["movies not on a list", "movies not on a list"] ]

  GENRES = [["Action", 28], ["Adventure", 12], ["Animation", 16], ["Comedy", 35], ["Crime", 80],
  ["Documentary", 99], ["Drama", 18], ["Family", 10751], ["Fantasy", 14], ["Foreign", 10769], ["History", 36],
  ["Horror", 27], ["Music", 10402], ["Mystery", 9648], ["Romance", 10749], ["Science Fiction", 878], ["TV Movie", 10770],
  ["Thriller", 53], ["War", 10752], ["Western", 37]]

  MPAA_RATINGS = [ ["R", "R"], ["NC-17", "NC-17"], ["PG-13", "PG-13"], ["G", "G"] ]

  SORT_BY = [ ["Popularity", "popularity"], ["Release date", "release_date"], ["Revenue", "revenue"],
  ["Vote average", "vote_average"], ["Vote count","vote_count"] ]

  YEAR_SELECT = [ ["Exact Year", "exact"], ["After This Year", "after"], ["Before This Year", "before"] ]

  scope :by_title, -> { order(:title) }
  scope :by_shortest_runtime, -> { order(:runtime) }
  scope :by_longest_runtime, -> { order(:runtime).reverse_order }
  scope :by_recent_release_date, -> { order(:release_date).reverse_order }
  scope :by_highest_vote_average, -> { order(:vote_average).reverse_order }
  scope :default_list_order, -> (list) do
    list.movies.order('CAST(listings.created_at as DATE) desc, listings.priority desc')
  end

  def self.by_tag_and_user(tag, user)
    joins(:taggings).where(taggings: { user_id: user.id }).where(taggings: { tag_id: tag.id })
  end

  def self.by_highest_priority(list)
    list.movies.sort_by { |movie| movie.priority(list) }.reverse
  end

  def self.by_recently_added(list)
    list.movies.sort_by { |movie| movie.date_added_to_list(list) }.reverse
  end

  def self.by_watched_by_user(list, user)
    list.movies.sort_by { |movie| movie.viewers.include?(user) ? 0 : 1  }
  end

  def self.by_watched_by_members(list)
    list.movies.sort_by { |movie| (movie.viewers.pluck(:id) & list.members.ids).any? ? 0 : 1  }
  end

  def self.by_unwatched_by_user(list, user)
    list.movies.sort_by { |movie| movie.viewers.include?(user) ? 1 : 0  }
  end

  def self.by_recently_watched_by_user(user)
    joins(:screenings).where(screenings: { user_id: user.id }).order("screenings.date_watched").reverse
  end

  def in_db #since search results are treated as @movie instances, this determines a @movie is in the database
    true
  end

  def times_seen_by(user)
    screenings.by_user(user).count
  end

  def self.watched_by_user(user)
    user.watched_movies.uniq
  end

  def self.unwatched_by_user(user)
    user_movies = user.all_movies.uniq
    seen_movies = user.watched_movies.uniq
    unseen_movies = (user_movies - seen_movies)
  end

  def most_recent_screening_by(user)
    screenings.by_user(user).sort_by(&:date_watched).last.date_watched.stamp("1/2/2001")
  end

  def date_added_to_list(list)
    Listing.find_by(list_id: list.id, movie_id: self.id).created_at
  end

  def self.tagged_with(tag_name, userlist)
    Tag.by_user_or_list(userlist).find_by_name!(tag_name).movies.uniq
  end

  def tag_list(userlist)
    tags.by_user_or_list(userlist).map
  end

  def self.by_genre(genre)
    where("genres && ARRAY[?]::varchar[]", genre)
  end

  def priority(list)
    listings.find_by(list_id: list.id).priority
  end

  def priority_text(list)
    p = listings.find_by(list_id: list.id).priority
    case p
    when 1 then "Bottom"
    when 2 then "Low"
    when 3 then "Normal"
    when 4 then "High"
    when 5 then "Top"
    end
  end
end
