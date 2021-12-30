class TVSeries
  attr_accessor :show_id, :first_air_date, :last_air_date, :created_by, :show_name, :backdrop_path, :poster_path, :number_of_episodes, :number_of_seasons, :tagline, :overview, :seasons, :actors, :seasons_posters

  def initialize(show_id:, first_air_date:, last_air_date:, created_by:, show_name:, backdrop_path:, poster_path:, number_of_episodes:, number_of_seasons:, tagline:, overview:, seasons:, seasons_posters: [], actors:)
    @show_id = show_id
    @first_air_date = first_air_date
    @last_air_date = last_air_date
    @created_by = created_by
    @show_name = show_name
    @backdrop_path = backdrop_path
    @poster_path = poster_path
    @number_of_episodes = number_of_episodes
    @number_of_seasons = number_of_seasons
    @tagline = tagline
    @overview = overview
    @seasons = seasons
    @seasons_posters = seasons_posters
    @actors = actors
  end

  def self.parse_search_records(results)
    results.map do|result|
      first_air_date = Date.parse(result[:first_air_date])&.stamp("1/2/2001") if result[:first_air_date].present?
      TVSeries.new(
        show_id: result[:id],
        first_air_date: first_air_date,
        last_air_date: nil,
        created_by: nil,
        show_name: result[:name],
        backdrop_path: result[:backdrop_path],
        poster_path: result[:poster_path],
        number_of_episodes: nil,
        number_of_seasons: nil,
        tagline: result[:tagline],
        overview: result[:overview],
        seasons: nil,
        seasons_posters: nil,
        actors: nil
      )
    end
  end

  def self.parse_record(result, show_id)
    first_air_date = Date.parse(result[:first_air_date]).stamp("1/2/2001") if result[:first_air_date].present?
    last_air_date = Date.parse(result[:last_air_date]).stamp("1/2/2001") if result[:last_air_date].present?
    seasons = (1..(result[:number_of_seasons])).to_a if result[:number_of_seasons].present?
    actors = TVCastMember.parse_records(result[:credits][:cast])
    seasons_posters = TVSeason.parse_season_posters(result[:seasons])

    new(
      show_id: show_id,
      first_air_date: first_air_date,
      last_air_date: last_air_date,
      created_by: result[:created_by],
      show_name: result[:name],
      backdrop_path: result[:backdrop_path],
      poster_path: result[:poster_path],
      number_of_episodes: result[:number_of_episodes],
      number_of_seasons: result[:number_of_seasons],
      tagline: result[:tagline],
      overview: result[:overview],
      seasons: seasons,
      seasons_posters: seasons_posters,
      actors: actors
    )
  end
end
