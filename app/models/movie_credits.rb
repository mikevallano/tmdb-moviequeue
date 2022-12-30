# frozen_string_literal: true

class MovieCredits
  attr_accessor :adult, :credit_id, :department, :job, :tmdb_id, :title, :poster_path, :date, :character

  def initialize(adult:, credit_id:, department:, job:, tmdb_id:, title:, poster_path:, date:, character:)
    @adult = adult
    @credit_id = credit_id
    @department = department
    @job = job
    @tmdb_id = tmdb_id
    @title = title
    @poster_path = poster_path
    @date = date
    @character = character
  end

  class << self
    def parse(results)
      results.map do |result|
        new(
          adult: result[:adult],
          credit_id: result[:credit_id],
          department: result[:department],
          job: result[:job],
          tmdb_id: result[:id],
          title: result[:title],
          poster_path: result[:poster_path],
          date: format_release_date(result[:release_date]),
          character: result[:character]
        )
      end.sort_by { |credit| credit.date }.reverse
    end

    private

    def format_release_date(date_data)
      date_data.present? ? Date.parse(date_data).stamp('2001') : 'Date unavailable'
    end
  end
end