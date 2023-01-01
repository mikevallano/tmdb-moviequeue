# frozen_string_literal: true

class MovieDirecting
  attr_accessor :director_id, :credit_id, :name, :department, :profile_path, :job

  def initialize(director_id:, credit_id:, name:, department:, profile_path:, job:)
    @director_id = director_id
    @credit_id = credit_id
    @name = name
    @profile_path = profile_path
    @department = department
    @job = job
  end

  def self.parse_results(results)
    results.map do |result|
      new(
        director_id: result[:id],
        credit_id: result[:credit_id],
        name: result[:name],
        profile_path: result[:profile_path],
        department: result[:department],
        job: result[:job],
      )
    end
  end
end