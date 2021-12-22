class TVCastMember
  attr_accessor :actor_id, :credit_id, :name, :character_name, :profile_path, :order

  def initialize(actor_id:, credit_id:, name:, character_name:, profile_path:, order:)
    @actor_id = actor_id
    @credit_id = credit_id
    @name = name
    @character_name = character_name
    @profile_path = profile_path
    @order = order
  end

  def self.parse_record(data)
    new(
      actor_id: data[:id],
      character_name: data[:character],
      credit_id: data[:credit_id],
      name: data[:name],
      order: data[:order],
      profile_path: data[:profile_path]
    )
  end

  def self.parse_records(json)
    json.map do |record|
      parse_record(record)
    end.sort_by { |r| r.order }.reverse
  end
end
