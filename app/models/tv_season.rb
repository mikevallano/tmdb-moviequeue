class TVSeason
  attr_accessor :series, :show_id, :air_date, :name, :overview, :season_id, :poster_path, :season_number, :credits, :cast_members, :episodes

  def initialize(series:, show_id:, air_date:, name:, overview:, season_id:, poster_path:, season_number:, credits:, cast_members:, episodes:)
    @series = series
    @show_id = show_id
    @air_date = air_date
    @name = name
    @overview = overview
    @season_id = season_id
    @poster_path = poster_path
    @season_number = season_number
    @credits = credits
    @cast_members = cast_members
    @episodes = episodes
  end

 def self.parse_record(series:, season_data:)
   air_date = Date.parse(season_data[:air_date]) if season_data[:air_date].present?
   new(
    series: series,
    show_id: series.show_id,
    air_date: air_date,
    name: season_data[:name],
    overview: season_data[:overview],
    season_id: season_data[:id],
    poster_path: season_data[:poster_path],
    season_number: season_data[:season_number],
    credits: season_data[:credits],
    cast_members: TVCastMember.parse_records(season_data[:credits][:cast]),
    episodes: TVEpisode.parse_records(season_data[:episodes])
   )
 end
end
