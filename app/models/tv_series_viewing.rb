# A TVSeriesViewing persists a log of how many times a person has engaged with watching a TV Series. It does not 
# track episode viewings, but rather the larger arc of when a user started the epic of watching a series and when
# they stopped. For example, a user may have watched "Parks and Recreation" as an entire series several times. 
# A user may have only watched "The Office" once. Therefore it is possible for a TV Series to have multiple 
# entries with different start and end dates. 

class TVSeriesViewing < ApplicationRecord
  belongs_to :user
  # TODO: add uniqueness to user_id, show_id...?
  # validates :show_id, uniqueness: {scope: :user_id, case_sensitive: false}
  # 
  
  # validates :username, presence: true, uniqueness: true

  validates_presence_of :title, :url, :show_id, :started_at
  
  MAX_ACTIVE_RECORDS = 8
  
  # before_create: :check_for_active_viewing
  def check_for_active_viewing
    # maybe this is just a find-or-create-by
  end
  

  def self.limit_reached?
    active.size >= MAX_ACTIVE_RECORDS
  end

  def self.active
    where(ended_at: nil)
  end
  
  def active?
    ended_at.nil?
  end


  # self.data = [
  #   { user_id: 1, title: 'Brooklyn Nine Nine', url: '/tmdb/tv_series?show_id=48891', show_id: '48891', started_at: '2024-12-01'.to_date, ended_at: nil },
  #   { user_id: 1, title: 'DS9', url: '/tmdb/tv_series?show_id=580', show_id: '580', started_at: '2024-12-01'.to_date, ended_at: nil },
  #   { user_id: 1, title: 'Enterprise', url: '/tmdb/tv_series?show_id=314', show_id: '314', started_at: '2024-12-01'.to_date, ended_at: nil },
  #   { user_id: 1, title: 'Monk', url: '/tmdb/tv_series?show_id=1695', show_id: '1695', started_at: '2024-12-01'.to_date, ended_at: nil },
  #   { user_id: 1, title: 'Parks & Rec', url: '/tmdb/tv_series?show_id=8592', show_id: '8592', started_at: '2024-12-01'.to_date, ended_at: nil },
  #   { user_id: 1, title: 'Resident Alien', url: '/tmdb/tv_series?show_id=96580', show_id: '96580', started_at: '2024-03-05'.to_date, ended_at: '2024-05-15'.to_date  },
  #   { user_id: 1, title: 'The Good Place', url: '/tmdb/tv_series?show_id=66573', show_id: '66573', started_at: '2024-10-02'.to_date, ended_at: '2024-10-12'.to_date },
  #   { user_id: 1, title: 'AP Bio - Season 1', url: 'tmdb/tv_season?season_number=1&show_id=71737&title=A.P.+Bio', show_id: '71737', started_at: '2024-12-01'.to_date, ended_at: nil },
  # ]
end







