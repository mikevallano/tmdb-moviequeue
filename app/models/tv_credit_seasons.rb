class TVCreditSeasons
  def initialize(air_date, season_number, poster_path)

    @air_date = air_date
    @season_number = season_number
    @poster_path = poster_path

  end #init

  attr_accessor :air_date, :season_number, :poster_path

  def self.parse_results(json)
    @seasons = []
    json.each do |result|
      @air_date = Date.parse(result[:air_date]).stamp("1/2/2001") if result[:air_date].present?
      @season_number = result[:season_number]
      @poster_path = result[:poster_path]
      if @season_number == 0
        @specials = TVCreditSeasons.new(@air_date, @season_number, @poster_path)
      else
        @season = TVCreditSeasons.new(@air_date, @season_number, @poster_path)
      end
      @seasons << @season
    end
    @seasons = @seasons.sort_by { |season| season.season_number }
    if @specials.present?
      @seasons << @specials
    end
    @seasons
  end #parse results

end #class