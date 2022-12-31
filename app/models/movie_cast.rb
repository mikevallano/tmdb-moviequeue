# frozen_string_literal: true

class MovieCast
  attr_accessor :title, :actor_id, :credit_id, :name, :character_name, :profile_path, :cast_id, :order

  def initialize(actor_id:, credit_id:, name:, character_name:, profile_path:, cast_id:, order:)
    @actor_id = actor_id
    @credit_id = credit_id
    @name = name
    @character_name = character_name
    @profile_path = profile_path
    @cast_id = cast_id
    @order = order
  end

  def self.parse_results(results)
    results.map do |result|
      new(
        actor_id: result[:id],
        credit_id: result[:credit_id],
        name: result[:name],
        character_name: result[:character],
        profile_path: result[:profile_path],
        order: result[:order],
        cast_id: result[:cast_id]
      )
    end
  end
end