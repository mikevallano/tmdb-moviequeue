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
      # we call it "advanced search" in the view
      def movie_advanced_search(params)
        actor1_search_result = search_person_by_name(params[:actor]) if params[:actor].present?
        not_found = "No results for '#{actor}'." unless actor_search_result.present?
        actor2_search_result = search_person_by_name(params[:actor2]) if params[:actor2].present?
        not_found = "No results for '#{actor2}'." unless actor2_search_result.present?
        person_ids = [actor1_search_result, actor2_search_result].map do |result|
          result.first[:id]
        end

        results = movie_discover_search(
          year: params[:year],
          year_search: params[:year_select],
          genre: params[:genre],
          people: person_ids,
          company: params[:company],
          mpaa_rating: params[:mpaa_rating],
          sort_by: params[:sort_by],
          page: params[:page])

        current_page = params[:page].to_i
        pagination = OpenStruct.new(
          current: current_page,
          previous: (current_page - 1 if current_page > 1),
          next: (current_page + 1 unless current_page >= results.total_pages),
          total: results.total_pages
        )

        # do some rescuing for when actor names are present but api results are not

        OpenStruct.new(
          movies: results.movies,
          not_found_message: not_found,
          pagination: pagination
        )
      end

      private
      # formerly tmdb_handler_movie_discover_search
      def movie_discover_search(year:, year_search:, genre:, people:, company:, mpaa_rating:, sort_by:, page:)
        # discover_url = "#{BASE_URL}/discover/movie?#{year_search}&with_genres=#{genre}&with_people=#{people}&with_companies=#{company}&certification_country=US&certification=#{mpaa_rating}&sort_by=#{sort_by}.desc&page=#{page}&api_key=#{ENV['tmdb_api_key']}"
        discover_url = "#{BASE_URL}/discover/movie?api_key=#{ENV['tmdb_api_key']}&certification_country=US"
        discover_url += "&with_genres=#{genre}" if genre.present?
        discover_url += "&with_people=#{people}" if people.present?
        discover_url += "&with_companies=#{company}" if company.present?
        discover_url += "&certification=#{mpaa_rating}" if mpaa_rating.present?
        discover_url += "&sort_by=#{sort_by}.desc" if sort_by.present?
        discover_url += "&page=#{page}" if page.present?
        if year.present? && year_search.present?
          discover_url += "primary_release_year=#{year}" if year_search == 'exact'
          discover_url += "primary_release_date.lte=#{years}-01-01" if year_search == 'before'
          discover_url += "primary_release_date.gte=#{years}-12-31" if year_search == 'after'
        elsif year.present?
          discover_url += "primary_release_year=#{year}" if year_search == 'exact'
        end

        results = JSON.parse(open(discover_url).read, symbolize_names: true)[:results]
        OpenStruct.new(
          total_pages: JSON.parse(open(discover_url).read, symbolize_names: true)[:total_pages],
          movies: MovieSearch.parse_results(results)
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
