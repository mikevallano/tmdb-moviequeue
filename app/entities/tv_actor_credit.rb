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
    seasons = TVCreditSeason.parse_records(record[:media][:seasons]).presence if record[:media][:seasons].present?
    episodes = TVEpisode.parse_records(record[:media][:episodes]).presence if record[:media][:episodes].present?
    episodes_by_number = episodes.sort_by { |e|e.episode_number } if episodes.present?
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
end
