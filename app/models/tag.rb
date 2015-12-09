class Tag < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :taggings
  has_many :movies, through: :taggings
  has_many :users, through: :taggings

  # def self.by_user(user)
  #   joins(:taggings).where(taggings: { user_id: user.id }).uniq
  # end

  # def self.by_list(list)
  #   by_user(:user => List.find(list.id).members)
  # end

  def self.by_user_or_list(userlist)
    if userlist.is_a?(User) || !userlist.members.present?
      joins(:taggings).where(taggings: { user_id: userlist.id }).uniq
    else
      userlist.members.each do |member|
        joins(:taggings).where(taggings: { user_id: member.id }).uniq
        # by_user_or_list(member) #TODO: check this out to try to call the method itself
      end
    end
  end

  def self.first_or_create_tags(names)
    names.each do |n|
      Tag.where(name: n).first_or_create!
    end
  end
end
