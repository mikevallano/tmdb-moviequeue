class TVEpisode
  attr_accessor :episode_id, :episode_number, :name, :air_date, :guest_stars, :season_number, :overview, :still_path

  def initialize(episode_id:, episode_number:, name:, air_date:, guest_stars:, season_number:, overview:, still_path:)
    @episode_id = episode_id
    @episode_number = episode_number
    @name = name
    @air_date = air_date
    @guest_stars = guest_stars
    @season_number = season_number
    @overview = overview
    @still_path = still_path
  end

  def self.parse_data(data)
    air_date = Date.parse(data[:air_date]) if data[:air_date].present?
    guest_stars = TVCast.parse_results(data[:guest_stars]) if data[:guest_stars].present?
    new(
      episode_id: data[:id],
      episode_number: data[:episode_number],
      name: data[:name],
      air_date: air_date,
      guest_stars: guest_stars,
      season_number: data[:season_number],
      overview: data[:overview],
      still_path: data[:still_path]
    )
  end
end
