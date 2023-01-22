class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  extend FriendlyId
  friendly_id :username, use: :history

  def should_generate_new_friendly_id?
    username_changed?
  end

  validates :username, presence: true, uniqueness: true
  validates_format_of :username, with: /\A[a-zA-Z0-9_\.]*\z/

  has_many :lists, foreign_key: 'owner_id', dependent: :destroy
  has_many :listings, through: :lists, dependent: :destroy

  has_many :memberships, foreign_key: 'member_id', dependent: :destroy
  has_many :member_lists, through: :memberships,
  source: :list

  has_many :member_listings, through: :member_lists,
  source: :listings

  has_many :movies, through: :listings
  has_many :member_movies, through: :member_lists,
  source: :movies, dependent: :destroy

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  has_many :sent_invites, class_name: 'Invite',
  foreign_key: 'sender_id', dependent: :destroy

  has_many :received_invites, class_name: 'Invite',
  foreign_key: 'receiver_id', dependent: :destroy

  has_many :reviews, dependent: :destroy
  has_many :reviewed_movies, through: :reviews,
  source: :movie

  has_many :ratings, dependent: :destroy
  has_many :rated_movies, through: :ratings,
  source: :movie

  has_many :screenings, dependent: :destroy
  has_many :watched_movies, through: :screenings,
  source: :movie

  def all_lists
    list_ids = lists.pluck(:id)
    member_list_ids = member_lists.pluck(:id)
    ids = (list_ids + member_list_ids).uniq
    List.where(id: ids)
  end

  def all_listings
    listing_ids = listings.pluck(:id)
    member_listing_ids = member_listings.pluck(:id)
    ids = (listing_ids + member_listing_ids).uniq
    Listing.where(id: ids)
  end

  def lists_except_movie(movie = nil)
    return all_lists_by_name unless movie&.in_db
    movie_list_ids = movie.lists.by_user(self).pluck(:id)
    all_lists.where.not(id: movie_list_ids)
  end

  def all_lists_by_name
    # TODO: not sure what this is acting weird
    # all_lists.order('lower(name) ASC')
    all_lists.sort_by { |list| list.name.downcase }
  end

  def all_movies
    list_movie_ids = movies.pluck(:id)
    member_movie_ids = member_movies.pluck(:id)
    watched_movie_ids = watched_movies.pluck(:id)
    all_ids = (list_movie_ids + member_movie_ids + watched_movie_ids).uniq
    Movie.where(id: all_ids)
  end

  def all_movies_by_title
    all_movies.order(title: :asc)
  end

  def all_movies_by_shortest_runtime
    all_movies.order(runtime: :asc)
  end

  def all_movies_by_longest_runtime
    all_movies.order(runtime: :desc)
  end

  def all_movies_by_recent_release_date
    all_movies.order(release_date: :desc)
  end

  def all_movies_by_highest_vote_average
    all_movies.order(vote_average: :desc)
  end

  def all_movies_by_recently_watched
    Movie.by_recently_watched_by_user(self)
  end

  # TODO: Rename or remove for clairity. It means not _your_ lists
  def all_movies_not_on_a_list
    movie_listing_ids = listings.pluck(:movie_id).uniq
    all_movies.where.not(id: movie_listing_ids)
  end

  def all_movies_by_unwatched
    Movie
      .where(id: all_movies.pluck(:id))
      .screenings_join_query(self)
      .order('max_date_watched ASC nulls first, movies.vote_average DESC')
  end

  # TODO: what's the difference between this and all_movies_by_recently_watched?
  def all_movies_by_watched
    Movie.by_recently_watched_by_user(self)
  end

  def movies_by_genre(genre)
    list_movie_ids = movies.pluck(:id)
    member_movie_ids = member_movies.pluck(:id)
    ids = (list_movie_ids + member_movie_ids).uniq
    Movie.where(id: ids).by_genre(genre)
  end

  def watched_movies_with_max_screening_date
    watched_movies
      .select("movies.*, MAX(TO_CHAR(screenings.date_watched, 'mm/dd/yyyy')) AS max_screening_date")
      .group('movies.id')
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

end
