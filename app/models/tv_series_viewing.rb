# A TVSeriesViewing persists a log of how many times a person has engaged with watching 
# a TV Series. It does not track *episode* viewings, but rather the larger arc of when 
# a user started the epic of watching a series and when they stopped. For example, a 
# user may have watched "Parks and Recreation" as an entire series several times. 
# A user may have only watched "The Office" once. Therefore it is possible for a 
# TV Series to have multiple entries with different start and end dates. 

class TVSeriesViewing < ApplicationRecord
  belongs_to :user

  # We don't want a user to have duplicate active viewings for a series
  validates :ended_at, uniqueness: { scope: [:user_id, :show_id] }
  validates_presence_of :title, :url, :show_id, :started_at
  
  scope :active, -> { where(ended_at: nil) }
  
  def active?
    ended_at.nil?
  end
end
