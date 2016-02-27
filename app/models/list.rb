class List < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:history, :scoped], :scope => :owner

  self.per_page = 20

  scope :main_lists, lambda { where(:is_main => true) }
  scope :public_lists, lambda { where(:is_public => true) }

  validates :name, :uniqueness => { :scope => :owner_id }, :presence => true, length: { maximum: 60 }

  belongs_to :owner, :class_name => "User"

  has_many :listings, dependent: :destroy
  has_many :movies, through: :listings

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships

  has_many :invites

  def self.by_user(user)
    (where(owner_id: user.id) | joins(:memberships).where(memberships: { member_id: user.id }))
  end


  def should_generate_new_friendly_id?
    name_changed?
  end

end
