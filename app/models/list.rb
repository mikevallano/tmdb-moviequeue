class List < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :owner, :class_name => "User"

  has_many :listings
  has_many :movies, through: :listings

  scope :by_user, lambda { |user| where(:owner_id => user.id) }
end
