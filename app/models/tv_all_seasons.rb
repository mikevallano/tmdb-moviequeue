class TVAllSeasons
  def initialize(season_number)

    @season_number = season_number

  end #init

  attr_accessor :season_number

  def self.parse_results(json, show_id)
    @seasons = []
    json.each do |result|
      @season_number = result[:season_number]
      @season = TVAllSeasons.new(@season_number)
      @seasons << @season
    end #results loop
    #put the misc/extras at the end
    #only show misc/extras if there are episodes for it.
    @misc_extras_url = "https://api.themoviedb.org/3/tv/#{show_id}/season/0?api_key=#{ENV['tmdb_api_key']}"
    begin
      @misc_extras_results = JSON.parse(open(@misc_extras_url).read, symbolize_names: true)
    rescue
      unless @misc_extras_results.present?
        @misc_extras_episode_count = 0
      end
    else
      @misc_extras_episode_count = @misc_extras_results[:episodes].count
    end #begin/rescue/end
    unless @misc_extras_episode_count > 0
      @seasons = @seasons.rotate(1)
      @seasons.delete_at(-1)
    end
    @seasons
  end #parse results

end #class