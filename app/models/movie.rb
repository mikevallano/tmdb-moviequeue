# frozen_string_literal: true

class Movie < ApplicationRecord
  self.per_page = 20

  extend FriendlyId
  friendly_id :title, use: :history

  validates :tmdb_id, uniqueness: :true, presence: true

  has_many :listings
  has_many :lists, through: :listings
  has_many :users, through: :listings
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :reviews
  has_many :ratings
  has_many :screenings
  has_many :viewers, through: :screenings, source: :user

  attr_accessor :production_companies

  scope :by_title, -> { order(:title) }
  scope :by_shortest_runtime, -> { order(runtime: :asc) }
  scope :by_longest_runtime, -> { order(runtime: :desc) }
  scope :by_recent_release_date, -> { order(release_date: :desc) }
  scope :by_highest_vote_average, -> { order(vote_average: :desc) }
  scope :default_list_order, -> (list) do
    list.movies.order('listings.created_at DESC, listings.priority DESC')
  end

  def self.by_tag_and_user(tag, user)
    joins(:taggings).where(taggings: { user_id: user.id }).where(taggings: { tag_id: tag.id })
  end

  def self.by_highest_priority(list)
    list.movies.order('listings.priority DESC')
  end

  def self.by_recently_added(list)
    list.movies.order('listings.created_at DESC')
  end

  def self.screenings_join_query(user)
    join_query = <<~SQL.squish
      LEFT OUTER JOIN screenings
        ON screenings.movie_id = movies.id
        AND screenings.user_id = #{user.id}
    SQL
    select('movies.*, max(screenings.date_watched) AS max_date_watched')
      .joins(join_query)
      .group('movies.id')
  end

  def self.by_watched_by_user(list, user)
    list
      .movies
      .screenings_join_query(user)
      .order('max_date_watched DESC nulls last, movies.vote_average DESC')
  end

  def self.by_unwatched_by_user(list, user)
    list
      .movies
      .screenings_join_query(user)
      .order('max_date_watched nulls first, movies.vote_average DESC')
  end

  # TODO: this should be the same query as user#all_movies_by_recently_watched
  def self.by_recently_watched_by_user(user)
    user
      .all_movies
      .screenings_join_query(user)
      .order('max_date_watched DESC nulls last, movies.vote_average DESC')
  end

  # Since search results are treated as @movie instances, this determines if a @movie is in the database
  def in_db
    true
  end

  def times_seen_by(user)
    screenings.by_user(user).count
  end

  def self.watched_by_user(user)
    user.watched_movies.distinct
  end

  def self.unwatched_by_user(user)
    user_movies = user.all_movies.uniq
    seen_movies = user.watched_movies.uniq
    unseen_movies = (user_movies - seen_movies)
  end

  def most_recent_screening_by(user)
    screenings.by_user(user).maximum(:date_watched).stamp('1/2/2001')
  end

  def date_added_to_list(list)
    Listing.find_by(list_id: list.id, movie_id: self.id).created_at
  end

  def self.tagged_with(tag_name, userlist)
    Tag.by_user_or_list(userlist).find_by_name!(tag_name).movies.distinct
  end

  def tag_list(userlist)
    tags.by_user_or_list(userlist)
  end

  def self.by_genre(genre)
    where('genres && ARRAY[?]::varchar[]', genre)
  end

  def priority(list)
    listings.find_by(list_id: list.id).priority
  end

  # TODO: thhis should be in a view helper
  def priority_text(list)
    priority = listings.find_by(list_id: list.id)&.priority
    case priority
    when 1 then 'Bottom'
    when 2 then 'Low'
    when 3 then 'Normal'
    when 4 then 'High'
    when 5 then 'Top'
    end
  end

  def streaming_service_providers
    @streaming_service_providers ||= StreamingServiceProviderDataService.get_providers(
      tmdb_id: self.tmdb_id,
      title: self.title,
      media_type: 'movie',
      media_format: 'movie',
      release_date: self.release_date
    )
  end
end
