class Screening < ActiveRecord::Base
  validates_presence_of :user
  validates_presence_of :movie

  belongs_to :user
  belongs_to :movie

  scope :by_user, lambda { |user| where(:user_id => user.id) }


  before_save :default_date

  def default_date
    self.date_watched ||= DateTime.now.to_date
  end
end

