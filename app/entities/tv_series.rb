# frozen_string_literal: true

class TVSeries
  attr_accessor :show_id, :first_air_date, :last_air_date, :show_name, :backdrop_path, :poster_path, :number_of_episodes, :number_of_seasons, :overview, :seasons, :actors
  alias_attribute :title, :show_name

  def initialize(show_id:, first_air_date:, last_air_date:, show_name:, backdrop_path:, poster_path:, number_of_episodes:, number_of_seasons:, overview:, seasons:, actors:)
    @show_id = show_id
    @first_air_date = first_air_date
    @last_air_date = last_air_date
    @show_name = show_name
    @backdrop_path = backdrop_path
    @poster_path = poster_path
    @number_of_episodes = number_of_episodes
    @number_of_seasons = number_of_seasons
    @overview = overview
    @seasons = seasons
    @actors = actors
  end

  def self.parse_search_records(results)
    results.map do|result|
      first_air_date = Date.parse(result[:first_air_date])&.stamp('1/2/2001') if result[:first_air_date].present?
      new(
        show_id: result[:id],
        first_air_date: first_air_date,
        last_air_date: nil,
        show_name: result[:name],
        backdrop_path: result[:backdrop_path],
        poster_path: result[:poster_path],
        number_of_episodes: nil,
        number_of_seasons: nil,
        overview: result[:overview],
        seasons: nil,
        actors: nil
      )
    end
  end

  def self.parse_record(result, show_id)
    first_air_date = Date.parse(result[:first_air_date]).stamp('1/2/2001') if result[:first_air_date].present?
    last_air_date = Date.parse(result[:last_air_date]).stamp('1/2/2001') if result[:last_air_date].present?
    seasons = (1..(result[:number_of_seasons])).to_a if result[:number_of_seasons].present?
    actors = TVCastMember.parse_records(result[:credits][:cast])

    new(
      show_id: show_id,
      first_air_date: first_air_date,
      last_air_date: last_air_date,
      show_name: result[:name],
      backdrop_path: result[:backdrop_path],
      poster_path: result[:poster_path],
      number_of_episodes: result[:number_of_episodes],
      number_of_seasons: result[:number_of_seasons],
      overview: result[:overview],
      seasons: seasons,
      actors: actors
    )
  end

  def streaming_service_providers
    @streaming_service_providers ||= StreamingServiceProviderDataService.get_providers(
      tmdb_id: self.show_id,
      title: self.show_name,
      media_type: 'tv',
      media_format: 'episodes'
    )
  end
end
