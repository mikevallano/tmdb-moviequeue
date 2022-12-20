# frozen_string_literal: true

module PersonDataService
  def self.get_person_names(query)
    data = Tmdb::Client.request(:multi_search, query: query)[:results]
    data.select { |result| result[:media_type] == 'person' }&.map { |result| result[:name] }&.uniq
  end

  def self.get_person_id(query)
    data = Tmdb::Client.request(:multi_search, query: query)[:results]
    data.select { |result| result[:media_type] == 'person' }&.first&.dig(:id)
  end

  def self.get_person_profile_data(person_id)
    person_data = Tmdb::Client.request(:person_data, person_id: person_id)
    movie_credits_data = Tmdb::Client.request(:person_movie_credits, person_id: person_id)
    tv_credits_data = Tmdb::Client.request(:person_tv_credits, person_id: person_id)

    OpenStruct.new(
      person_id: person_id,
      profile: MoviePersonProfile.parse_result(person_data),
      movie_credits: MoviePersonCredits.parse_result(movie_credits_data),
      tv_credits: TVPersonCredits.parse_result(tv_credits_data)
    )
  end
end
