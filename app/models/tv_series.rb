class TVSeries
  def initialize(show_id, first_air_date, last_air_date, show_name, backdrop_path, poster_path, number_of_episodes, number_of_seasons, overview, seasons, actors)

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

  end #init

  attr_accessor :show_id, :first_air_date, :last_air_date, :show_name, :backdrop_path, :poster_path, :number_of_episodes, :number_of_seasons, :overview, :seasons, :actors

  def self.parse_results(result, show_id)
    @show_id = show_id
    @first_air_date = Date.parse(result[:first_air_date]).stamp("1/2/2001") if result[:first_air_date].present?
    @last_air_date = Date.parse(result[:last_air_date]).stamp("1/2/2001") if result[:last_air_date].present?
    @show_name = result[:name]
    @backdrop_path = result[:backdrop_path]
    @poster_path = result[:poster_path]
    @number_of_episodes = result[:number_of_episodes]
    @number_of_seasons = result[:number_of_seasons]
    @overview = result[:overview]
    @seasons = (1..(result[:number_of_seasons])).to_a
    @actors = TVCast.parse_results(result[:credits][:cast])
    @series = TVSeries.new(@show_id, @first_air_date, @last_air_date, @show_name, @backdrop_path, @poster_path, @number_of_episodes, @number_of_seasons, @overview, @seasons, @actors)
  end #parse results

end #class