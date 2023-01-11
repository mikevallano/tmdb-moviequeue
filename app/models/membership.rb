class Membership < ApplicationRecord
  belongs_to :list
  belongs_to :member, class_name: 'User'

  scope :by_user, -> (user) { where(member_id: user.id) }
end
