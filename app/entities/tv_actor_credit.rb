# frozen_string_literal: true

class TVActorCredit
  attr_accessor :show_name, :show_id, :actor_name, :actor_id, :character, :seasons, :episodes, :profile_path, :known_for

  def initialize(show_name:, show_id:, actor_name:, actor_id:, character:, seasons:, episodes:, profile_path:, known_for:)
    @actor_id = actor_id
    @actor_name = actor_name
    @character = character
    @episodes = episodes
    @known_for = known_for
    @profile_path = profile_path
    @show_id = show_id
    @show_name = show_name
    @seasons = seasons
  end

  def self.parse_record(record)
    seasons = TVCreditSeason.parse_records(record[:media][:seasons]).sort_by {|s| s.name}
    episodes = TVEpisode.parse_records(record[:media][:episodes]).presence if record[:media][:episodes].present?
    episodes_by_number = episodes.present? ? episodes.sort_by { |e|e.episode_number } : []
    new(
      actor_name: record[:person][:name],
      actor_id: record[:person][:id],
      character: record[:media][:character],
      episodes: episodes_by_number,
      known_for: record[:person][:known_for],
      profile_path: record[:person][:profile_path],
      show_id: record[:media][:id],
      show_name: record[:media][:name],
      seasons: seasons
    )
  end

  def in_main_cast?
    # If an actor's character doesn't have a name, then they are not in the main cast.
    return false if @character.empty?
    # When an actor's episodes array is empty and the character has a name, they are in the main cast.
    return true if @episodes.empty?
    
    # There are cases when an actor appeared as a guest before or after being in the main cast. 
    # We reserve making this API call only for that condition. Note the actor must be in the final
    # series cast data, so if they were replaced by another actor, this will return false.
    series_data = TVSeriesDataService.get_tv_series_data(@show_id)
    series_data.actors.map(&:actor_id).include?(@actor_id)
  end
end
