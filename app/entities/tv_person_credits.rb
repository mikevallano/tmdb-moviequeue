# frozen_string_literal: true

class TVPersonCredits
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
      directing: TVCredits.parse(result[:crew].select { |crew| crew[:job] == 'Director' }),
      editing: TVCredits.parse(result[:crew].select { |crew| crew[:job] == 'Editor' }),
      writing: TVCredits.parse(result[:crew ].select { |crew| crew[:job] == 'Writer' }),
      screenplay: TVCredits.parse(result[:crew].select { |crew| crew[:job] == 'Screenplay' }),
      producer: TVCredits.parse(result[:crew].select { |crew| crew[:job].include?('Producer') }),
      actor: TVCredits.parse(result[:cast])
    )
  end
end