class Tag < ApplicationRecord

  validates :name, :uniqueness => :true, :presence => true, length: { maximum: 25 }

  has_many :taggings
  has_many :movies, through: :taggings
  has_many :users, through: :taggings

  def self.by_user_or_list(userlist)
    if userlist.is_a?(User)
      joins(:taggings).where(taggings: { user_id: userlist.id }).uniq
    elsif userlist.is_a?(List) && !userlist.members.present?
      joins(:taggings).where(taggings: { user_id: userlist.owner.id }).uniq
    else
      joins(:taggings).where(taggings: { user_id: userlist.members.ids }).uniq
    end
  end

  def self.first_or_create_tags(names)
    names.each do |n|
      Tag.where(name: n).first_or_create!
    end
  end
end
