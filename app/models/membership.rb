class Membership < ActiveRecord::Base
  belongs_to :list
  belongs_to :member, :class_name => "User"

  scope :by_user, lambda { |user| where(:member_id => user.id) }
end
