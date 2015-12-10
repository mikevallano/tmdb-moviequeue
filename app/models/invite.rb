class Invite < ActiveRecord::Base
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  belongs_to :list

  validates_presence_of :email
  validates_format_of :email, :with => /@/

  require 'securerandom'

  def generate_token
    SecureRandom.uuid + [Time.now.to_i, rand(100..1000)].join
  end

  def to_existing_user?
    User.exists?(email: self.email)
  end

  def find_invitee
    User.find_by_email(self.email)
  end

end