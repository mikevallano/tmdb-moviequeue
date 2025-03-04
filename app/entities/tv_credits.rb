# frozen_string_literal: true

class TVCredits
  attr_accessor :credit_id, :department, :job, :show_id, :show_name, :poster_path, :character, :episodes, :seasons, :first_air_date

  def initialize(credit_id:, department:, job:, show_id:, show_name:, poster_path:, character:, episodes:, seasons:, first_air_date:)
    @credit_id = credit_id
    @department = department
    @job = job
    @show_id = show_id
    @show_name = show_name
    @poster_path = poster_path
    @character = character
    @episodes = episodes
    @seasons = seasons
    @first_air_date = first_air_date
  end

  class << self
    def parse(results)
      results.map do |result|
        new(
          credit_id: result[:credit_id],
          department: result[:department],
          job: result[:job],
          show_id: result[:id],
          show_name: result[:name],
          poster_path: result[:poster_path],
          character: result[:character],
          episodes: result[:episodes],
          seasons: result[:seasons],
          first_air_date: format_first_air_date(result[:first_air_date])
        )
      end.sort_by { |credit| credit.first_air_date }.reverse
    end

    private

    def format_first_air_date(date_data)
      date_data.present? ? Date.parse(date_data).stamp('2001') : 'Date unavailable'
    end
  end
end