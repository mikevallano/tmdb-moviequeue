# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'.freeze

    class << self
      # TOTALLY WIP
      def movies_between_two_actors_search(actor_one_name, actor_two_name)
        actor_one_results = search_person_by_name(actor_one_name)
        actor_two_results = search_person_by_name(actor_two_name)
        not_found_message = actor_one_results.not_found_message.presence || actor_two_results.not_found_message.presence

        if not_found_message.present?
          OpenStruct.new(not_found_message: not_found_message)
        else
          actor_one = tmdb_handler_movie_more(actor_one_results.movies.first.tmdb_id)
          actor_two = tmdb_handler_movie_more(actor_two_results.movies.first.tmdb_id)
          OpenStruct.new(
            actor_one: actor_one,
            actor_two: actor_two,
            common_movies: actor_one.movies & actor_two.movies,
            not_found_message: nil
          )
        end
      end

      # formerly tmdb_handler_discover_search
      def movie_advanced_search(actor1: nil, actor2: nil,)
      end



      private
      # formerly tmdb_handler_movie_discover_search
      def movie_discover_search(year_search:, genre:, people:, company:, mpaa_rating:, sort_by:, page:)
        discover_url = "#{BASE_URL}/discover/movie?#{year_search}&with_genres=#{genre}&with_people=#{people}&with_companies=#{company}&certification_country=US&certification=#{mpaa_rating}&sort_by=#{sort_by}.desc&page=#{page}&api_key=#{ENV['tmdb_api_key']}"
        results = JSON.parse(open(discover_url).read, symbolize_names: true)[:results]
        OpenStruct.new(
          total_pages = JSON.parse(open(discover_url).read, symbolize_names: true)[:total_pages],
          movies = MovieSearch.parse_results(results)
        )
      end

      def search_person_by_name(person_name) # make private
        searchable_name = I18n.transliterate(person_name)
        search_url = "#{BASE_URL}/search/person?query=#{searchable_name}&api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)[:results]
      end
    end
  end
end
