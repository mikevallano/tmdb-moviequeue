class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :lists, :foreign_key => "owner_id"
  has_many :listings, through: :lists

  has_many :memberships, :foreign_key => "member_id"
  has_many :member_lists, :through => :memberships,
  :source => :list

  has_many :movies, through: :listings
  has_many :member_movies, :through => :member_lists,
  :source => :movies

  has_many :taggings
  has_many :tags, through: :taggings

  has_many :sent_invites, :class_name => "Invite",
  :foreign_key => "sender_id"

  has_many :received_invites, :class_name => "Invite",
  :foreign_key => "receiver_id"

  def all_lists
    (self.lists | self.member_lists).uniq
  end

  def all_movies
    (self.movies | self.member_movies).uniq
  end


end
