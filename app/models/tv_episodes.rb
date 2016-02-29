class TVEpisodes
  def initialize(air_date, name, season_number, episode_number, overview, still_path)

    @air_date = air_date
    @name = name
    @season_number = season_number
    @episode_number = episode_number
    @overview = overview
    @still_path = still_path

  end #init

  attr_accessor :air_date, :name, :episode_number, :season_number, :episode_number, :overview, :still_path

  def self.parse_results(json)
    @episodes = []
    json.each do |result|
      @air_date = Date.parse(result[:air_date]).stamp("1/2/2001") if result[:air_date].present?
      @name = result[:name]
      @season_number = result[:season_number]
      @episode_number = result[:episode_number]
      @overview = result[:overview]
      @still_path = result[:still_path]
      @episode = TVEpisodes.new(@air_date, @name, @season_number, @episode_number, @overview, @still_path)
      @episodes << @episode
    end
    @episodes
  end #parse results

end #class