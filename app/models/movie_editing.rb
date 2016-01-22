class MovieEditing
  def initialize(editor_id, credit_id, name, department, profile_path, job )

    @editor_id = editor_id
    @credit_id = credit_id
    @name = name
    @profile_path = profile_path
    @department = department
    @job = job

  end #init

  attr_accessor :editor_id, :credit_id, :name, :department, :profile_path, :job

  def self.parse_results(json)
    @editors = []
    json.each do |result|
      @editor_id = result[:id]
      @credit_id = result[:credit_id]
      @name = result[:name]
      @profile_path = result[:profile_path]
      @job = result[:job]
      @department = result[:department]

      @editor = MovieEditing.new(@editor_id, @credit_id, @name, @department, @profile_path, @job)
      @editors << @editor
    end #results loop
    @editors
  end #parse results

end