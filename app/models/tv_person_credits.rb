class TVPersonCredits

  def initialize(directing, editing, writing, screenplay, producer, actor)

    @directing = directing
    @editing = editing
    @writing = writing
    @screenplay = screenplay
    @producer = producer
    @actor = actor

  end #init

  attr_accessor :directing, :editing, :writing, :screenplay, :producer, :actor

  def self.parse_result(result)
    @actor = TVCredits.parse(result[:cast])
    @directing = TVCredits.parse(result[:crew].select { |crew| crew[:job] == "Director" })
    @editing = TVCredits.parse(result[:crew].select { |crew| crew[:job] == "Editor" })
    @writing = TVCredits.parse(result[:crew ].select { |crew| crew[:job] == "Writer" })
    @screenplay = TVCredits.parse(result[:crew].select { |crew| crew[:job] == "Screenplay" })
    @producer = TVCredits.parse(result[:crew].select { |crew| crew[:job].include?("Producer") })

    TVPersonCredits.new(@directing, @editing, @writing, @screenplay, @producer, @actor)

  end #parse result

end #class