# frozen_string_literal: true

module Tmdb
  module Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'
    API_KEY = ENV['tmdb_api_key']

    class << self
      def get_movie_search_results(movie_title)
        data = request(:movie_search, query: movie_title)[:results]
        not_found = "No results for '#{movie_title}'." if data.blank?
        movies = MovieSearch.parse_results(data) if data.present?

        OpenStruct.new(
          movie_title: movie_title,
          not_found_message: not_found,
          query: movie_title,
          movies: movies
        )
      end

      def get_advanced_movie_search_results(params)
        data = if params[:actor_name].present?
          person_id = request(:person_search, query: params[:actor_name])[:results]&.first&.dig(:id)
          request(:discover_search, params.merge(people: person_id))
        else
          request(:discover_search, params)
        end

        movie_results = data.dig(:results)
        not_found = "No results for provided parameters." if movie_results.blank?
        movies = MovieSearch.parse_results(movie_results) if movie_results.present?
        total_pages = data.fetch(:total_pages)
        current_page = params[:page].to_i

        OpenStruct.new(
          sort_by: params[:sort_by],
          genre: params[:genre],
          company: params[:company],
          date: params[:date],
          timeframe: params[:timeframe],
          mpaa_rating: params[:mpaa_rating],
          actor_name: params[:actor_name],
          movies: movies,
          not_found_message: not_found,
          page: params[:page],
          current_page: current_page,
          previous_page: (current_page - 1 if current_page > 1),
          next_page: (current_page + 1 unless current_page >= total_pages),
          total_pages: total_pages
        )
      end

      def get_movies_for_actor(actor_name:, page:, sort_by:)
        page = page.presence || 1
        sort_by = sort_by.presence || 'popularity'
        person_data = request(:person_search, query: actor_name)[:results]&.first

        if person_data.blank?
          return OpenStruct.new(
            not_found_message: "No actors found for '#{actor_name}'."
          )
        end

        movie_params = {
          people: person_data[:id],
          page: page,
          sort_by: sort_by
        }
        movie_data = request(:discover_search, movie_params)
        movie_results = movie_data[:results]
        total_pages = movie_data&.fetch(:total_pages)

        not_found_message = "No movies found for '#{actor_name}'." if movie_results.blank?
        current_page = page.to_i

        OpenStruct.new(
          id: person_data[:id],
          actor: person_data,
          actor_name: person_data[:name],
          movies: MovieSearch.parse_results(movie_results),
          not_found_message: not_found_message,
          current_page: current_page,
          previous_page: (current_page - 1 if current_page > 1),
          next_page: (current_page + 1 unless current_page >= total_pages),
          total_pages: total_pages
        )
      end

      def get_movie_data(tmdb_movie_id)
        data = request(:movie_data, movie_id: tmdb_movie_id)
        MovieMore.initialize_from_parsed_data(data)
      end

      def get_movie_cast(tmdb_movie_id)
        data = request(:movie_data, movie_id: tmdb_movie_id)

        director_credits = data.dig(:credits, :crew)&.select { |crew| crew[:job] == 'Director' }
        editor_credits = data.dig(:credits, :crew)&.select { |crew| crew[:job] == 'Editor' }

        OpenStruct.new(
          movie: get_movie_data(tmdb_movie_id),
          actors: MovieCast.parse_results(data.dig(:credits, :cast)),
          directors: MovieDirecting.parse_results(director_credits),
          editors: MovieEditing.parse_results(editor_credits)
        )
      end

      def get_movie_titles(query)
        data = request(:movie_search, query: query)[:results]
        data.map { |d| d[:title] }.uniq
      end

      # TODO: Move this to the Movie class as update_with_api_data
      def update_movie(movie)
        # I'm not sure why this method uses HTTParty instead
        tmdb_id = movie.tmdb_id.to_s
        movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{API_KEY}&append_to_response=trailers,credits,releases"
        api_result = begin
                       HTTParty.get(movie_url).deep_symbolize_keys
                     rescue StandardError
                       nil
                     end
        raise Error, "API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}" unless api_result

        if api_result[:status_code] == 34 && api_result[:status_message]&.include?('could not be found')
          puts "Movie not found, so not updated. Title: #{movie.title}. tmdb_id: #{tmdb_id}"
          return
        elsif api_result[:id]&.to_s != tmdb_id
          raise Error, "API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}"
        end

        updated_data = MovieMore.initialize_from_parsed_data(api_result)

        if movie.title != updated_data.title
          puts "Movie title doesn't match. tmdb_id: #{tmdb_id}. Current title: #{movie.title}. Title in TMDB: #{updated_data.title}"
        end

        movie.update!(
          title: updated_data.title,
          imdb_id: updated_data.imdb_id,
          genres: updated_data.genres,
          actors: updated_data.actors,
          backdrop_path: updated_data.backdrop_path,
          poster_path: updated_data.poster_path,
          release_date: updated_data.release_date,
          overview: updated_data.overview,
          trailer: movie.trailer || updated_data.trailer,
          director: updated_data.director,
          director_id: updated_data.director_id,
          vote_average: updated_data.vote_average,
          popularity: updated_data.popularity,
          runtime: updated_data.runtime,
          mpaa_rating: updated_data.mpaa_rating,
          updated_at: Time.current
        )
      rescue ActiveRecord::RecordInvalid => e
        raise Error, "#{movie.title} failed update. #{e.message}"
      end

      def get_common_actors_between_movies(movie_one_title, movie_two_title)
        movie_one_results = get_movie_search_results(movie_one_title)
        movie_two_results = get_movie_search_results(movie_two_title)
        not_found_message = movie_one_results.not_found_message.presence || movie_two_results.not_found_message.presence

        if not_found_message.present?
          OpenStruct.new(not_found_message: not_found_message)
        else
          movie_one = get_movie_data(movie_one_results.movies.first.tmdb_id)
          movie_two = get_movie_data(movie_two_results.movies.first.tmdb_id)
          OpenStruct.new(
            movie_one: movie_one,
            movie_two: movie_two,
            common_actors: movie_one.actors & movie_two.actors,
            not_found_message: nil
          )
        end
      end

      def get_common_movies_between_multiple_actors(actor_names: nil, paginate_actor_names: nil, page: nil, sort_by: nil)
        page = page.presence || 1
        sort_by = sort_by.presence || 'popularity'
        names = actor_names.uniq.reject { |name| name == '' }.compact.presence || paginate_actor_names.presence.split(';')
        return if names.blank?

        not_found_messages = []
        person_ids = []
        actor_names = []

        names.compact.each do |name|
          data = request(:person_search, query: name)[:results]&.first
          if data.blank?
            not_found_messages << "No actor found for '#{name}'."
          else
            person_ids << data[:id]
            actor_names << data[:name]
          end
        end

        if not_found_messages.present?
          return OpenStruct.new(
            not_found_message: not_found_messages.compact.join(' ')
          )
        end

        movie_response = request(:discover_search,
                                 people: person_ids.join(','),
                                 page: page,
                                 sort_by: sort_by)

        if movie_response[:results].blank?
          return OpenStruct.new(
            not_found_message: "No results for movies with #{actor_names.to_sentence}."
          )
        end

        current_page = page.to_i
        OpenStruct.new(
          actor_names: actor_names,
          paginate_actor_names: actor_names.join(';'),
          common_movies: MovieSearch.parse_results(movie_response[:results]),
          not_found_message: nil,
          current_page: current_page,
          previous_page: (current_page - 1 if current_page > 1),
          next_page: (current_page + 1 unless current_page >= movie_response[:total_pages]),
          total_pages: movie_response[:total_pages]
        )
      end

      def get_person_names(query)
        data = request(:multi_search, query: query)[:results]
        data.select { |result| result[:media_type] == 'person' }&.map { |result| result[:name] }&.uniq
      end

      def get_person_profile_data(person_id)
        person_data = request(:person_data, person_id: person_id)
        movie_credits_data = request(:person_movie_credits, person_id: person_id)
        tv_credits_data = request(:person_tv_credits, person_id: person_id)

        OpenStruct.new(
          person_id: person_id,
          profile: MoviePersonProfile.parse_result(person_data),
          movie_credits: MoviePersonCredits.parse_result(movie_credits_data),
          tv_credits: TVPersonCredits.parse_result(tv_credits_data)
        )
      end

      def get_actor_tv_appearance_credits(credit_id)
        data = request(:credits_data, credit_id: credit_id)
        TVActorCredit.parse_record(data)
      end

      def get_tv_series_names(query)
        data = request(:tv_series_search, query: query)[:results]
        data.map { |d| d[:name] }.uniq
      end

      def get_tv_series_search_results(query)
        data = request(:tv_series_search, query: query)[:results]
        TVSeries.parse_search_records(data) if data.present?
      end

      def get_tv_series_data(series_id)
        data = request(:tv_series_data, series_id: series_id)
        TVSeries.parse_record(data, series_id)
      end

      def get_tv_season_data(series:, season_number:)
        params = { series_id: series.show_id, season_number: season_number }
        data = request(:tv_season_data, params)
        TVSeason.parse_record(
          series: series,
          season_data: data
        )
      end

      def get_tv_episode_data(series_id:, season_number:, episode_number:)
        params = { series_id: series_id, season_number: season_number, episode_number: episode_number }
        data = request(:tv_episode_data, params)
        TVEpisode.parse_record(data)
      end

      private

      def request(endpoint, params)
        return { results: [] } if params[:query].present? && searchable_query(params[:query]).empty?

        api_path = case endpoint
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
          when :discover_search then url_for_movie_discover_search(params)
        end
        JSON.parse(open("#{BASE_URL}#{api_path}").read, symbolize_names: true)
      end

      def url_for_movie_discover_search(params)
        api_path = "/discover/movie?api_key=#{ENV['tmdb_api_key']}&certification_country=US"
        api_path += "&with_people=#{params[:people]}" if params[:people].present?
        api_path += "&with_genres=#{params[:genre]}" if params[:genre].present?
        api_path += "&with_companies=#{params[:company]}" if params[:company].present?
        api_path += "&certification=#{params[:mpaa_rating]}" if params[:mpaa_rating].present?
        api_path += "&sort_by=#{params[:sort_by]}.desc" if params[:sort_by].present?
        api_path += "&page=#{params[:page]}"
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
        I18n.transliterate(query.gsub(/[^0-9a-z ]/i, ''))
      end
    end
  end
end
