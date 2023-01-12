class Screening < ApplicationRecord
  validates_presence_of :user
  validates_presence_of :movie

  belongs_to :user
  belongs_to :movie

  scope :by_user, -> (user) { where(user_id: user.id) }


  before_save :default_date

  def default_date
    # time is set to US Central in application.rb
    self.date_watched ||= DateTime.now.to_date
  end
end

