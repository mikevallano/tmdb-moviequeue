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
    @actor = MovieCredits.parse(result[:cast])
    @directing = MovieCredits.parse(result[:crew].select { |crew| crew[:job] == "Director" })
    @editing = MovieCredits.parse(result[:crew].select { |crew| crew[:job] == "Editor" })
    @writing = MovieCredits.parse(result[:crew ].select { |crew| crew[:job] == "Writer" })
    @screenplay = MovieCredits.parse(result[:crew].select { |crew| crew[:job] == "Screenplay" })
    @producer = MovieCredits.parse(result[:crew].select { |crew| crew[:job].include?("Producer") })

    MoviePersonCredits.new(@movies, @tv, @directing, @editing, @writing, @screenplay, @producer, @actor)

  end #parse result

end #class