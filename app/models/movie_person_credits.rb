class MoviePersonCredits

  def initialize(movies, tv, directing, editing, writing, screenplay, producer, actor)

    @movies = movies
    @tv = tv
    @directing = directing
    @editing = editing
    @writing = writing
    @screenplay = screenplay
    @producer = producer
    @actor = actor

  end #init

  attr_accessor :movies, :tv, :directing, :editing, :writing, :screenplay, :producer, :actor

  def self.parse_result(result)
    @actor = result[:cast]
    @directing = result[:crew].select { |crew| crew[:job] == "Director" }
    @editing = result[:crew].select { |crew| crew[:job] == "Editor" }
    @writing = result[:crew ].select { |crew| crew[:job] == "Writer" }
    @screenplay = result[:crew].select { |crew| crew[:job] == "Screenplay" }
    @producer = result[:crew].select { |crew| crew[:job] == "Producer" }

    MoviePersonCredits.new(@movies, @tv, @directing, @editing, @writing, @screenplay, @producer, @actor)

  end #parse result

end #class