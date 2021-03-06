class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  extend FriendlyId
  friendly_id :username, :use => :history

  def should_generate_new_friendly_id?
    username_changed?
  end

  validates :username, :presence => true, :uniqueness => true
  validates_format_of :username, with: /\A[a-zA-Z0-9_\.]*\z/

  has_many :lists, :foreign_key => "owner_id", dependent: :destroy
  has_many :listings, through: :lists, dependent: :destroy

  has_many :memberships, :foreign_key => "member_id", dependent: :destroy
  has_many :member_lists, :through => :memberships,
  :source => :list

  has_many :member_listings, through: :member_lists,
  :source => :listings

  has_many :movies, through: :listings
  has_many :member_movies, :through => :member_lists,
  :source => :movies, dependent: :destroy

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  has_many :sent_invites, :class_name => "Invite",
  :foreign_key => "sender_id", dependent: :destroy

  has_many :received_invites, :class_name => "Invite",
  :foreign_key => "receiver_id", dependent: :destroy

  has_many :reviews, dependent: :destroy
  has_many :reviewed_movies, through: :reviews,
  :source => :movie

  has_many :ratings, dependent: :destroy
  has_many :rated_movies, through: :ratings,
  :source => :movie

  has_many :screenings, dependent: :destroy
  has_many :watched_movies, through: :screenings,
  :source => :movie

  def all_lists
    (self.lists | self.member_lists).uniq
  end

  def all_listings
    (self.listings | self.member_listings)
  end

  def lists_except_movie(movie = nil)
    if movie.present? && movie.in_db
      (all_lists - movie.lists.by_user(self))
        .sort_by { |list| list.name.downcase }
    else
      all_lists_by_name
    end
  end

  def all_lists_by_name
    self.all_lists.sort_by { |list| list.name.downcase }
  end

  def all_movies
    (self.movies.all + self.member_movies.all + self.watched_movies.all).uniq
  end

  def all_movies_by_title
    self.all_movies.sort_by { |movie| movie.title }
  end

  def all_movies_by_shortest_runtime
    self.all_movies.sort_by { |movie| movie.runtime }
  end

  def all_movies_by_longest_runtime
    self.all_movies.sort_by { |movie| movie.runtime }.reverse
  end

  def all_movies_by_recent_release_date
    self.all_movies.sort_by { |movie| movie.release_date }.reverse
  end

  def all_movies_by_highest_vote_average
    self.all_movies.sort_by { |movie| movie.vote_average }.reverse
  end

  def all_movies_by_recently_watched
    watched = self.watched_movies.order('screenings.date_watched').reverse.uniq
    (watched + all_movies).uniq
  end

  def all_movies_not_on_a_list
    on_lists = self.movies.all
    on_member_lists = self.member_movies
    not_on_a_list = (self.all_movies - on_lists - on_member_lists).uniq
  end

  def all_movies_by_unwatched
    self.all_movies.sort_by { |movie| [ movie.viewers.include?(self) ? 1 : 0, movie.vote_average ]  }
  end

  def all_movies_by_watched
    self.all_movies.sort_by { |movie| movie.viewers.include?(self) ? 0 : 1  }
  end

  def movies_by_genre(genre)
    (self.movies.by_genre(genre) | self.member_movies.by_genre(genre))
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
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

end
