class TVSeason
  def initialize(episode_number, name, air_date, guest_stars, overview, still_path)
    @episode_number = episode_number
    @name = name
    @air_date = air_date
    @guest_stars = guest_stars
    @overview = overview
    @still_path = still_path
  end #init

  attr_accessor :episode_number, :name, :air_date, :guest_stars, :overview, :still_path

  def self.parse_results(json)
    @episodes = []
    json.each do |result|
      @episode_number = result[:episode_number]
      @name = result[:name]
      @air_date = Date.parse(result[:air_date]) if result[:air_date].present?
      if result[:guest_stars].present?
        @guest_stars = TVCast.parse_results(result[:guest_stars])
      else
        @guest_stars = nil
      end
      @overview = result[:overview]
      @still_path = result[:still_path]
      # TODO: refactor this into a TvEpisode object
      @episode = TVSeason.new(@episode_number, @name, @air_date, @guest_stars, @overview, @still_path)
      @episodes << @episode
    end
    @episodes

  end #parse results

end #class
