class Movie < ActiveRecord::Base

  validates_presence_of :tmdb_id
  validates_uniqueness_of :tmdb_id

  has_many :listings
  has_many :lists, through: :listings

  has_many :taggings
  has_many :tags, through: :taggings

  def self.by_user(user)
    joins(:lists).where(lists: { owner_id: user.id }).uniq
  end

  def self.tagged_with(name, user)
    Tag.find_by_name!(name).movies.by_user(user)
  end

  def tag_list(user)
    tags.by_user(user).uniq.map(&:name)
  end
end
