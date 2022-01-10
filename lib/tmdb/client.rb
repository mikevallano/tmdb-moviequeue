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
        actor_search_result = search_person_by_name(params[:actor]) if params[:actor].present?

        if actor_search_result.not_found_message.present?
          return OpenStruct.new(
            movies: [],
            not_found_message: actor_search_result.not_found_message,
          )
        else
          results = movie_discover_search(
            year: params[:year],
            year_select: params[:year_select],
            genre: params[:genre],
            people: actor_search_result.data[:id],
            company: params[:company],
            mpaa_rating: params[:mpaa_rating],
            sort_by: params[:sort_by],
            page: params[:page]
          )

          current_page = params[:page].to_i
          OpenStruct.new(
            original_search: params,
            movies: results.movies,
            not_found_message: nil,
            current_page: current_page,
            previous_page: (current_page - 1 if current_page > 1),
            next_page: (current_page + 1 unless current_page >= results.total_pages),
            total_pages: results.total_pages
          )
        end
      end

      private
      # formerly tmdb_handler_movie_discover_search
      def movie_discover_search(params)
        # discover_url = "#{BASE_URL}/discover/movie?#{year_select}&with_genres=#{genre}&with_people=#{people}&with_companies=#{company}&certification_country=US&certification=#{mpaa_rating}&sort_by=#{sort_by}.desc&page=#{page}&api_key=#{ENV['tmdb_api_key']}"
        discover_url = "#{BASE_URL}/discover/movie?api_key=#{ENV['tmdb_api_key']}&certification_country=US"
        discover_url += "&with_people=#{params[:people]}" if params[:people].present?
        discover_url += "&with_genres=#{params[:genre]}" if params[:genre].present?
        discover_url += "&with_companies=#{params[:company]}" if params[:company].present?
        discover_url += "&certification=#{params[:mpaa_rating]}" if params[:mpaa_rating].present?
        discover_url += "&sort_by=#{params[:sort_by]}.desc" if params[:sort_by].present?
        discover_url += "&page=#{params[:page]}"
        if params[:year].present? && params[:year_select].present?
          discover_url += "&primary_release_year=#{params[:year]}" if params[:year_select] == 'exact'
          discover_url += "&primary_release_date.lte=#{params[:year]}-01-01" if params[:year_select] == 'before'
          discover_url += "&primary_release_date.gte=#{params[:year]}-12-31" if params[:year_select] == 'after'
        elsif params[:year].present?
          discover_url += "&primary_release_year=#{params[:year]}"
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
        results = JSON.parse(open(search_url).read, symbolize_names: true)[:results]
        not_found_message = "No results for '#{person_name}'." if results.blank?

        OpenStruct.new(
          data: results&.first,
          not_found_message: not_found_message
        )
      end
    end
  end
end
