# frozen_string_literal: true

class MoviePersonCredits
  attr_accessor :directing, :editing, :writing, :screenplay, :producer, :actor

  def initialize(directing:, editing:, writing:, screenplay:, producer:, actor:)
    @directing = directing
    @editing = editing
    @writing = writing
    @screenplay = screenplay
    @producer = producer
    @actor = actor
  end

  def self.parse_result(result)
    new(
      directing: MovieCredits.parse(result[:crew].select { |crew| crew[:job] == 'Director' }),
      editing: MovieCredits.parse(result[:crew].select { |crew| crew[:job] == 'Editor' }),
      writing: MovieCredits.parse(result[:crew ].select { |crew| crew[:job] == 'Writer' }),
      screenplay: MovieCredits.parse(result[:crew].select { |crew| crew[:job] == 'Screenplay' }),
      producer: MovieCredits.parse(result[:crew].select { |crew| crew[:job].include?('Producer') }),
      actor: MovieCredits.parse(result[:cast])
    )
  end
end