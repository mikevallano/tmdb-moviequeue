# frozen_string_literal: true

class MovieEditing
  attr_accessor :editor_id, :credit_id, :name, :department, :profile_path, :job

  def initialize(editor_id:, credit_id:, name:, department:, profile_path:, job:)
    @editor_id = editor_id
    @credit_id = credit_id
    @name = name
    @profile_path = profile_path
    @department = department
    @job = job
  end

  def self.parse_results(results)
    results.map do |result|
      new(
        editor_id: result[:id],
        credit_id: result[:credit_id],
        name: result[:name],
        department: result[:department],
        profile_path: result[:profile_path],
        job: result[:job]
      )
    end
  end
end