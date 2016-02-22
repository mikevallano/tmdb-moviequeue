class TVCredits

  def initialize(credit_id, department, job, show_id, show_name, poster_path, character, first_air_date)

    @credit_id = credit_id
    @department = department
    @job = job
    @show_id = show_id
    @show_name = show_name
    @poster_path = poster_path
    @character = character
    @first_air_date = first_air_date

  end #init

  attr_accessor :credit_id, :department, :job, :show_id, :show_name, :poster_path, :character, :first_air_date

  def self.parse(json)
    @credits = []
    json.each do |result|
      @credit_id = result[:credit_id]
      @department = result[:department]
      @job = result[:job]
      @show_id = result[:id]
      @show_name = result[:name]
      @poster_path = result[:poster_path]
      @character = result[:character]
      if result[:first_air_date].present?
        @first_air_date = Date.parse(result[:first_air_date]).stamp("2001")
      else
        @first_air_date = "Date unavailable"
      end

      @credit = TVCredits.new(@credit_id, @department, @job, @show_id, @show_name, @poster_path, @character, @first_air_date)
      @credits << @credit
    end #loop
    @credits = @credits.sort_by{ |credit| credit.first_air_date }.reverse
  end #parse

end #class