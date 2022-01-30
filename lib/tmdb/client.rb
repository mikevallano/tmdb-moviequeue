# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'.freeze

    class << self
      def movie_autocomplete(query)
        search_url = "#{BASE_URL}/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
        tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
        tmdb_response[:results].map{ |result| result[:title] }.uniq
      end

      def person_autocomplete(query)
        search_url = "#{BASE_URL}/search/multi?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
        tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
        person_results = tmdb_response[:results].select{ |result| result[:media_type] == "person"}
        person_results.map{ |result| result[:name] }.uniq
      end
    end
  end
end
