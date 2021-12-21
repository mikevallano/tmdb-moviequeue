class TVActorCredit
  def initialize(show_name, show_id, actor_name, actor_id, character, seasons, episodes)

    @show_name = show_name
    @show_id = show_id
    @actor_name = actor_name
    @actor_id = actor_id
    @character = character
    @seasons = seasons
    @episodes = episodes

  end #init

  attr_accessor :show_name, :show_id, :actor_name, :actor_id, :character, :seasons, :episodes

  def self.parse_results(result)
    @show_name = result[:media][:name]
    @show_id = result[:media][:id]
    @actor_name = result[:person][:name]
    @actor_id = result[:person][:id]
    @character = result[:media][:character]

    if result[:media][:seasons].present?
      @seasons = TVCreditSeason.parse_records(result[:media][:seasons])
    else
      @seasons = nil
    end
    if result[:media][:episodes].present?
      @episodes = TVEpisode.parse_records(result[:media][:episodes])
    else
      @episodes = nil
    end
    @credit = TVActorCredit.new(@show_name, @show_id, @actor_name, @actor_id, @character, @seasons, @episodes)
  end #parse results

end #class
