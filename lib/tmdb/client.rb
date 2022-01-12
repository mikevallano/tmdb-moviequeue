# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'.freeze

    class << self
      def movies_by_actor(params)
        person = search_person_by_name(params[:actor_name])

        if person.not_found_message.present?
          OpenStruct.new(not_found_message: person.not_found_message)
        else
          movie_results = movie_discover_search(
            people: person.data[:id],
            page: params[:page],
            sort_by: params[:sort_by]
          )

          current_page = params[:page].to_i
          OpenStruct.new(
            actor: person.data,
            actor_name: person.data[:name],
            movies: movie_results.data,
            not_found_message: nil,
            current_page: current_page,
            previous_page: (current_page - 1 if current_page > 1),
            next_page: (current_page + 1 unless current_page >= movie_results.total_pages),
            total_pages: movie_results.total_pages
          )
        end
      end

      def movies_between_multiple_actors_search(actor_names:, **params)
        names = actor_names.uniq.reject{|name| name == ''}.presence || params[:paginate_names].presence
        return if names.empty?

        actor_results = names.compact.map do |name|
          search_person_by_name(name)
        end.compact

        person_data = actor_results.map do |result|
          result.data
        end

        person_ids = actor_results.map do |result|
          result.data[:id]
        end.join(',')

        actor_names = actor_results.map do |result|
          result.data[:name]
        end

        not_found_messages = actor_results.select do |result|
          result.not_found_message.presence
        end.join(',')

        if not_found_messages.present?
          OpenStruct.new(not_found_message: not_found_messages)
        else
          movie_results = movie_discover_search(
            people: person_ids,
            page: params[:page],
            sort_by: params[:sort_by]
          )

          current_page = params[:page].to_i
          OpenStruct.new(
            actors: person_data,
            actor_names: actor_names,
            common_movies: movie_results.data,
            not_found_message: nil,
            current_page: current_page,
            previous_page: (current_page - 1 if current_page > 1),
            next_page: (current_page + 1 unless current_page >= movie_results.total_pages),
            total_pages: movie_results.total_pages
          )
        end
      end

      def movie_advanced_search(params)
        actor_search_result = search_person_by_name(params[:actor]) if params[:actor].present?

        if actor_search_result.not_found_message.present?
          return OpenStruct.new(
            movies: [],
            not_found_message: actor_search_result.not_found_message,
          )
        else
          movie_results = movie_discover_search(
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
            movies: movie_results.data,
            not_found_message: nil,
            current_page: current_page,
            previous_page: (current_page - 1 if current_page > 1),
            next_page: (current_page + 1 unless current_page >= movie_results.total_pages),
            total_pages: movie_results.total_pages
          )
        end
      end

      private

      def movie_discover_search(params)
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
        not_found_message = "No results for this query." if results.blank?

        OpenStruct.new(
          data: MovieSearch.parse_results(results),
          not_found_message: not_found_message,
          total_pages: JSON.parse(open(discover_url).read, symbolize_names: true)[:total_pages]
        )
      end

      def search_person_by_name(person_name)
        searchable_name = I18n.transliterate(person_name.strip)
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
