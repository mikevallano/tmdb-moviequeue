class TVSeason
  attr_accessor :series, :show_id, :air_date, :name, :overview, :season_id, :poster_path, :season_number, :credit, :episodes

  def initialize(series:, show_id:, air_date:, name:, overview:, season_id:, poster_path:, season_number:, credit:, episodes:)
    @series = series
    @show_id = show_id
    @air_date = air_date
    @name = name
    @overview = overview
    @season_id = season_id
    @poster_path = poster_path
    @season_number = season_number
    @credit = credit
    @episodes = episodes
  end

 def self.parse_record(series:, show_id:, season_data:)
   air_date = Date.parse(season_data[:air_date]) if season_data[:air_date].present?
   new(
    series: series,
    show_id: show_id,
    air_date: air_date,
    name: season_data[:name],
    overview: season_data[:overview],
    season_id: season_data[:id],
    poster_path: season_data[:poster_path],
    season_number: season_data[:season_number],
    credit: season_data[:credits],
    episodes: TVEpisode.parse_records(season_data[:episodes])
   )
 end
end
