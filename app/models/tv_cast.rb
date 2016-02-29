class TVCast
  def initialize(actor_id, credit_id, name, character_name, profile_path, order )

    @actor_id = actor_id
    @credit_id = credit_id
    @name = name
    @character_name = character_name
    @profile_path = profile_path
    @order = order

  end #init

  attr_accessor :actor_id, :credit_id, :name, :character_name, :profile_path, :order


  def self.parse_results(json)
    @actors = []
    json.each do |result|
      @actor_id = result[:id]
      @credit_id = result[:credit_id]
      @name = result[:name]
      @character_name = result[:character]
      @profile_path = result[:profile_path]
      @order = result[:order]

      @actor = TVCast.new(@actor_id, @credit_id, @name, @character_name, @profile_path, @order)
      @actors << @actor
    end #results loop
    @actors
  end #parse results

end #class