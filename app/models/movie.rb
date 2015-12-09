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

  def self.tagged_with(tag_name, userlist)
    Tag.by_user_or_list(userlist).find_by_name!(tag_name).movies.uniq
  end

  def tag_list(userlist)
    tags.by_user_or_list(userlist).map(&:name)
  end
end
