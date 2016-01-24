class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  extend FriendlyId
  friendly_id :username, :use => :history

  validates :username, :presence => true, :uniqueness => true
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true
  validate :validate_username

  has_many :lists, :foreign_key => "owner_id"
  has_many :listings, through: :lists

  has_many :memberships, :foreign_key => "member_id"
  has_many :member_lists, :through => :memberships,
  :source => :list

  has_many :member_listings, through: :member_lists,
  :source => :listings

  has_many :movies, through: :listings
  has_many :member_movies, :through => :member_lists,
  :source => :movies

  has_many :taggings
  has_many :tags, through: :taggings

  has_many :sent_invites, :class_name => "Invite",
  :foreign_key => "sender_id"

  has_many :received_invites, :class_name => "Invite",
  :foreign_key => "receiver_id"

  has_many :reviews
  has_many :reviewed_movies, through: :reviews,
  :source => :movie

  has_many :ratings
  has_many :rated_movies, through: :ratings,
  :source => :movie

  has_many :screenings
  has_many :screened_movies, through: :screenings,
  :source => :movie

  def all_lists
    (self.lists | self.member_lists).uniq
  end

  def all_listings
    (self.listings | self.member_listings)
  end

  def lists_except_movie(movie = nil)
    if movie.present? && Movie.exists?(tmdb_id: movie.tmdb_id)
      except_lists = []
      self.lists.each do |list|
        except_lists << list
      end
      self.member_lists.each do |list|
        except_lists << list
      end
      movie_lists = Movie.find_by(tmdb_id: movie.tmdb_id).lists.by_user(self)
      lists_except_movie = (except_lists - movie_lists)
    else
      all_lists
    end
  end

  def all_movies
    (self.movies.all + self.member_movies.all + self.screened_movies.all).uniq
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

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

end
