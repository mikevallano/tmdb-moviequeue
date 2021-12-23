class TVCreditSeason
  attr_accessor :air_date, :episode_count, :id, :name, :overview, :poster_path, :season_number, :show_id

  def initialize(air_date:, episode_count:, id:, name:, overview:, poster_path:, season_number:, show_id:)
    @air_date = air_date
    @episode_count = episode_count
    @id = id
    @name = name
    @overview = overview
    @poster_path = poster_path
    @season_number = season_number
    @show_id = show_id
  end

  def self.parse_records(json)
    json.map do |record|
      parse_record(record)
    end.sort_by { |r| r.season_number }
  end

  def self.parse_record(record)
    air_date = Date.parse(record[:air_date]).stamp("1/2/2001") if record[:air_date].present?
    new(
      air_date: air_date,
      episode_count: record[:episode_count],
      id: record[:id],
      name: record[:name],
      overview: record[:overview],
      poster_path: record[:poster_path],
      season_number: record[:season_number],
      show_id: record[:show_id]
    )
  end
end
