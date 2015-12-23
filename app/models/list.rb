class List < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:history, :scoped], :scope => :owner

  scope :by_user, lambda { |user| where(:owner_id => user.id) }
  scope :main_lists, lambda { where(:is_main => true) }

  validates_presence_of :name
  validates :name, :uniqueness => { :scope => :owner_id }

  belongs_to :owner, :class_name => "User"

  has_many :listings
  has_many :movies, through: :listings

  has_many :memberships
  has_many :members, through: :memberships

  has_many :invites


  def should_generate_new_friendly_id?
    name_changed?
  end

end
