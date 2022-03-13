# frozen_string_literal: true

module Tmdb
  module Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'
    API_KEY = ENV['tmdb_api_key']

    class << self
      def request(endpoint, params)
        return { results: [] } if params[:query].present? && searchable_query(params[:query]).empty?

        api_path = build_url(endpoint, params)
        response = open("#{BASE_URL}#{api_path}").read
        JSON.parse(response, symbolize_names: true)
      end

      private

      def build_url(endpoint, params)
        case endpoint
        when :discover_search then build_url_for_movie_discover_search(params)
        when :credits_data then "/credit/#{params[:credit_id]}?api_key=#{API_KEY}"
        when :person_data then "/person/#{params[:person_id]}?api_key=#{API_KEY}"
        when :person_search then "/search/person?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}"
        when :person_movie_credits then "/person/#{params[:person_id]}/movie_credits?api_key=#{API_KEY}"
        when :person_tv_credits then "/person/#{params[:person_id]}/tv_credits?api_key=#{API_KEY}"
        when :movie_search then "/search/movie?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}"
        when :movie_data then "/movie/#{params[:movie_id]}?api_key=#{API_KEY}&append_to_response=trailers,credits,releases"
        when :tv_series_search then "/search/tv?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}"
        when :tv_series_data then "/tv/#{params[:series_id]}?api_key=#{API_KEY}&append_to_response=credits"
        when :tv_season_data then "/tv/#{params[:series_id]}/season/#{params[:season_number]}?api_key=#{API_KEY}&append_to_response=credits"
        when :tv_episode_data then "/tv/#{params[:series_id]}/season/#{params[:season_number]}/episode/#{params[:episode_number]}?api_key=#{API_KEY}"
        when :multi_search then "/search/multi?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}"
        end
      end

      def build_url_for_movie_discover_search(params)
        page = params[:page].presence || 1
        sort_by = params[:sort_by].presence || 'popularity'
        api_path = "/discover/movie?api_key=#{ENV['tmdb_api_key']}&certification_country=US"
        api_path += "&with_people=#{params[:people]}" if params[:people].present?
        api_path += "&with_genres=#{params[:genre]}" if params[:genre].present?
        api_path += "&with_companies=#{params[:company]}" if params[:company].present?
        api_path += "&certification=#{params[:mpaa_rating]}" if params[:mpaa_rating].present?
        api_path += "&sort_by=#{sort_by}.desc"
        api_path += "&page=#{page}"
        if params[:year].present? && params[:timeframe].present?
          api_path += "&primary_release_year=#{params[:year]}" if params[:timeframe] == 'exact'
          api_path += "&primary_release_date.lte=#{params[:year]}-01-01" if params[:timeframe] == 'before'
          api_path += "&primary_release_date.gte=#{params[:year]}-12-31" if params[:timeframe] == 'after'
        elsif params[:year].present?
          api_path += "&primary_release_year=#{params[:year]}"
        end
        api_path
      end

      def searchable_query(query)
        return unless query.present?
        # If a user searches for a name that starts with an `&` the api call fails.
        # This ensures no non alphanumeric characters make it into the query string.
        I18n.transliterate(query).gsub(/[^0-9a-z ]/i, '')
      end
    end
  end
end
