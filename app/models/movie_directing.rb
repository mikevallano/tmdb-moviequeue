class MovieDirecting
  def initialize(director_id, credit_id, name, department, profile_path, job )

    @director_id = director_id
    @credit_id = credit_id
    @name = name
    @profile_path = profile_path
    @department = department
    @job = job

  end #init

  attr_accessor :director_id, :credit_id, :name, :department, :profile_path, :job

  def self.parse_results(json)
    @directors = []
    json.each do |result|
      @director_id = result[:id]
      @credit_id = result[:credit_id]
      @name = result[:name]
      @profile_path = result[:profile_path]
      @job = result[:job]
      @department = result[:department]

      @director = MovieDirecting.new(@director_id, @credit_id, @name, @department, @profile_path, @job)
      @directors << @director
    end #results loop
    @directors
  end #parse results

end #class