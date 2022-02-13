# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'.freeze
    API_KEY = ENV['tmdb_api_key']

    class << self
      def movie_search(movie_title)
        data = request(:movie_search, { query: movie_title })&.dig(:results)
        not_found = "No results for '#{query}'." if data.blank?
        movies = MovieSearch.parse_results(data) if data.present?

        OpenStruct.new(
          movie_title: movie_title,
          not_found_message: not_found,
          query: query,
          movies: movies
        )
      end

      def get_movie_data(tmdb_movie_id)
        data = request(:movie_data, { movie_id: tmdb_movie_id })
        MovieMore.initialize_from_parsed_data(data)
      end

      def movie_cast(tmdb_movie_id)
        data = request(:movie_data, { movie_id: tmdb_movie_id })
        director_credits = data[:credits][:crew].select { |crew| crew[:job] == "Director" }
        editor_credits = data[:credits][:crew].select { |crew| crew[:job] == "Editor" }

        OpenStruct.new(
          movie: get_movie_data(tmdb_movie_id),
          actors: MovieCast.parse_results(data[:credits][:cast]),
          directors: MovieDirecting.parse_results(director_credits),
          editors: MovieEditing.parse_results(editor_credits),
        )
      end

      def movie_autocomplete(query)
        data = request(:movie_search, { query: query })&.dig(:results)
        data.map { |d| d[:title] }.uniq
      end

      def update_movie(movie)
        # I'm not sure why this method uses HTTParty instead
        tmdb_id = movie.tmdb_id.to_s
        movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{API_KEY}&append_to_response=trailers,credits,releases"
        api_result = HTTParty.get(movie_url).deep_symbolize_keys rescue nil
        raise Error.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}") unless api_result
        if api_result[:status_code] == 34 && api_result[:status_message]&.include?('could not be found')
          puts "Movie not found, so not updated. Title: #{movie.title}. tmdb_id: #{tmdb_id}"
          return
        elsif api_result[:id]&.to_s != tmdb_id
          raise Error.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}")
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
      rescue ActiveRecord::RecordInvalid => error
        raise Error.new("#{movie.title} failed update. #{error.message}")
      end

      def common_actors_between_movies(movie_one_title, movie_two_title)
        movie_one_results = movie_search(movie_one_title)
        movie_two_results = movie_search(movie_two_title)
        not_found_message = movie_one_results.not_found_message.presence || movie_two_results.not_found_message.presence

        if not_found_message.present?
          OpenStruct.new(not_found_message: not_found_message)
        else
          movie_one = get_movie_data(movie_one_results.movies.first.tmdb_id)
          movie_two = get_movie_data.movie_data(movie_two_results.movies.first.tmdb_id)
          OpenStruct.new(
            movie_one: movie_one,
            movie_two: movie_two,
            common_actors: movie_one.actors & movie_two.actors,
            not_found_message: nil
          )
        end
      end

      def person_autocomplete(query)
        data = request(:multi_search, { query: query })&.dig(:results)
        data.select{ |result| result[:media_type] == "person"}.map{ |result| result[:name] }.uniq
      end

      def person_detail_search(person_id)
        person_data = request(:person_data, { person_id: person_id })
        movie_credits_data = request(:person_movie_credits, { person_id: person_id })
        tv_credits_data = request(:person_tv_credits, { person_id: person_id })

        OpenStruct.new(
          person_id: person_id,
          profile: MoviePersonProfile.parse_result(person_data),
          movie_credits: MoviePersonCredits.parse_result(movie_credits_data),
          tv_credits: TVPersonCredits.parse_result(tv_credits_data)
        )
      end

      def tv_actor_appearance_credits(credit_id)
        data = request(:credits_data, { credit_id: credit_id })
        TVActorCredit.parse_record(data)
      end

      def tv_series_autocomplete(query)
        data = request(:tv_series_search, { query: query })&.dig(:results)
        data.map{ |d| d[:name] }.uniq
      end

      def tv_series_search(query)
        data = request(:tv_series_search, { query: query })&.dig(:results)
        TVSeries.parse_search_records(data) if data.present?
      end

      def tv_series(series_id)
        data = request(:tv_series_data, { series_id: series_id })
        TVSeries.parse_record(data, series_id)
      end

      def tv_season(series:, season_number:)
        data = request(:tv_season_data, { series_id: series.show_id, season_number: season_number })
        TVSeason.parse_record(
          series: series,
          season_data: data
        )
      end

      def tv_episode(series_id:, season_number:, episode_number:)
        data = request(:tv_episode_data, { series_id: series_id, season_number: season_number, episode_number: episode_number })
        TVEpisode.parse_record(data)
      end

      private

      def request(endpoint, params)
        endpoints = {
          credits_data:         "/credit/#{params[:credit_id]}?api_key=#{API_KEY}",
          person_data:          "/person/#{params[:person_id]}?api_key=#{API_KEY}",
          person_movie_credits: "/person/#{params[:person_id]}/movie_credits?api_key=#{API_KEY}",
          person_tv_credits:    "/person/#{params[:person_id]}/tv_credits?api_key=#{API_KEY}",
          movie_search:         "/search/movie?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}",
          movie_data:           "/movie/#{params[:movie_id]}?api_key=#{API_KEY}&append_to_response=trailers,credits,releases",
          tv_series_search:     "/search/tv?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}",
          tv_series_data:       "/tv/#{params[:series_id]}?api_key=#{API_KEY}&append_to_response=credits",
          tv_season_data:       "/tv/#{params[:series_id]}/season/#{params[:season_number]}?api_key=#{API_KEY}&append_to_response=credits",
          tv_episode_data:      "/tv/#{params[:series_id]}/season/#{params[:season_number]}/episode/#{params[:episode_number]}?api_key=#{API_KEY}",
          multi_search:         "/search/multi?api_key=#{API_KEY}&query=#{searchable_query(params[:query])}",
          discover_search:      url_for_movie_discover_search(params)
        }
        url = "#{BASE_URL}#{endpoints[endpoint]}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def url_for_movie_discover_search(params)
        url = "#{BASE_URL}/discover/movie?api_key=#{ENV['tmdb_api_key']}&certification_country=US"
        url += "&with_people=#{params[:people]}" if params[:people].present?
        url += "&with_genres=#{params[:genre]}" if params[:genre].present?
        url += "&with_companies=#{params[:company]}" if params[:company].present?
        url += "&certification=#{params[:mpaa_rating]}" if params[:mpaa_rating].present?
        url += "&sort_by=#{params[:sort_by]}.desc" if params[:sort_by].present?
        url += "&page=#{params[:page]}"
        if params[:year].present? && params[:year_select].present?
          url += "&primary_release_year=#{params[:year]}" if params[:year_select] == 'exact'
          url += "&primary_release_date.lte=#{params[:year]}-01-01" if params[:year_select] == 'before'
          url += "&primary_release_date.gte=#{params[:year]}-12-31" if params[:year_select] == 'after'
        elsif params[:year].present?
          url += "&primary_release_year=#{params[:year]}"
        end
        url
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
