class MovieCredits

  def initialize(adult, credit_id, department, job, tmdb_id, title, poster_path, date, character)

    @adult = adult
    @credit_id = credit_id
    @department = department
    @job = job
    @tmdb_id = tmdb_id
    @title = title
    @poster_path = poster_path
    @date = date
    @character = character

  end #init

  attr_accessor :adult, :credit_id, :department, :job, :tmdb_id, :title, :poster_path, :date, :character

  def self.parse(json)
    @credits = []
    json.each do |result|
      @adult = result[:adult]
      @credit_id = result[:credit_id]
      @department = result[:department]
      @job = result[:job]
      @tmdb_id = result[:id]
      @title = result[:title]
      @poster_path = result[:poster_path]
      if result[:release_date].present?
        @date = Date.parse(result[:release_date]).stamp("2001")
      else
        @date = "Date unavailable"
      end
      @character = result[:character] if result[:character].present?

      @credit = MovieCredits.new(@adult, @credit_id, @department, @job, @tmdb_id, @title, @poster_path, @date, @character)
      @credits << @credit
    end #loop
    @credits = @credits.sort_by{ |credit| credit.date }.reverse
  end #parse

end #class