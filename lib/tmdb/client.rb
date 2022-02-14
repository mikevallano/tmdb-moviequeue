# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'
    API_KEY = ENV['tmdb_api_key']

    class << self
      def movie_search(movie_title)
        query = I18n.transliterate(movie_title).titlecase
        data = get_parsed_movie_search_results(query)
        not_found = "No results for '#{query}'." if data.blank?
        movies = MovieSearch.parse_results(data) if data.present?

        OpenStruct.new(
          movie_title: movie_title,
          not_found_message: not_found,
          query: query,
          movies: movies
        )
      end

      def get_movies_for_actor(actor_name:, page:, sort_by:)
        person_url = url_for_person_search(actor_name)
        person_data = request_data_from_api(person_url)&.dig(:results)&.first

        return OpenStruct.new(not_found_message: "No actors found for '#{actor_name}'.") if person_data.blank?

        movie_url = url_for_movie_discover_search(
          people: person_data[:id],
          page: page,
          sort_by: sort_by
        )
        movie_data = request_data_from_api(movie_url)
        movie_results = movie_data&.dig(:results)
        total_pages = movie_data&.dig(:total_pages)

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
        data = get_parsed_movie_data(tmdb_movie_id)
        MovieMore.initialize_from_parsed_data(data)
      end

      def movie_cast(tmdb_movie_id)
        data = get_parsed_movie_data(tmdb_movie_id)
        director_credits = data[:credits][:crew].select { |crew| crew[:job] == 'Director' }
        editor_credits = data[:credits][:crew].select { |crew| crew[:job] == 'Editor' }

        OpenStruct.new(
          movie: get_movie_data(tmdb_movie_id),
          actors: MovieCast.parse_results(data[:credits][:cast]),
          directors: MovieDirecting.parse_results(director_credits),
          editors: MovieEditing.parse_results(editor_credits)
        )
      end

      def movie_autocomplete(query)
        data = get_parsed_movie_search_results(query)
        data.map { |d| d[:title] }.uniq
      end

      def update_movie(movie)
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
          movie_one = GuaranteedMovie.find_or_initialize_from_api(movie_one_results.movies.first.tmdb_id)
          movie_two = GuaranteedMovie.find_or_initialize_from_api(movie_two_results.movies.first.tmdb_id)
          OpenStruct.new(
            movie_one: movie_one,
            movie_two: movie_two,
            common_actors: movie_one.actors & movie_two.actors,
            not_found_message: nil
          )
        end
      end

      def person_autocomplete(query)
        data = get_parsed_multi_search_results(query)
        person_results = data.select{ |result| result[:media_type] == "person"}
        person_results.map{ |result| result[:name] }.uniq
      end

      def person_detail_search(person_id)
        bio_results = get_parsed_person_bio(person_id)
        movie_credits_results = get_parsed_person_movie_credits(person_id)
        tv_credits_results = get_parsed_person_tv_credits(person_id)

        OpenStruct.new(
          person_id: person_id,
          profile: MoviePersonProfile.parse_result(bio_results),
          movie_credits: MoviePersonCredits.parse_result(movie_credits_results),
          tv_credits: TVPersonCredits.parse_result(tv_credits_results)
        )
      end

      def tv_actor_appearance_credits(credit_id)
        data = get_parsed_credit(credit_id)
        TVActorCredit.parse_record(data)
      end

      def tv_series_autocomplete(query)
        data = get_parsed_tv_search_results(query)
        data.map{ |d| d[:name] }.uniq
      end

      def tv_series_search(query)
        data = get_parsed_tv_search_results(query)
        TVSeries.parse_search_records(data) if data.present?
      end

      def tv_series(series_id)
        data = get_parsed_tv_series_data(series_id)
        TVSeries.parse_record(data, series_id)
      end

      def tv_season(series:, season_number:)
        season_data = get_parsed_tv_season_data(series: series, season_number: season_number)
        TVSeason.parse_record(
          series: series,
          season_data: season_data
        )
      end

      def tv_episode(series_id:, season_number:, episode_number:)
        episode_data = get_parsed_tv_episode_data(
          series_id: series_id,
          season_number: season_number,
          episode_number: episode_number
        )
        TVEpisode.parse_record(episode_data)
      end

      private

      def get_parsed_credit(credit_id)
        url = "#{BASE_URL}/credit/#{credit_id}?api_key=#{API_KEY}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_person_bio(person_id)
        url = "#{BASE_URL}/person/#{person_id}?api_key=#{API_KEY}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_person_movie_credits(person_id)
        url = "#{BASE_URL}/person/#{person_id}/movie_credits?api_key=#{API_KEY}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_person_tv_credits(person_id)
        url = "#{BASE_URL}/person/#{person_id}/tv_credits?api_key=#{API_KEY}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_movie_data(movie_id)
        url = "#{BASE_URL}/movie/#{movie_id}?api_key=#{API_KEY}&append_to_response=trailers,credits,releases"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_tv_series_data(series_id)
        url = "#{BASE_URL}/tv/#{series_id}?api_key=#{API_KEY}&append_to_response=credits"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_tv_season_data(series:, season_number:)
        url = "#{BASE_URL}/tv/#{series.show_id}/season/#{season_number}?api_key=#{API_KEY}&append_to_response=credits"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_tv_episode_data(series_id:, season_number:, episode_number:)
        url = "#{BASE_URL}/tv/#{series_id}/season/#{season_number}/episode/#{episode_number}?api_key=#{API_KEY}"
        JSON.parse(open(url).read, symbolize_names: true)
      end

      def get_parsed_tv_search_results(series_name)
        url = "#{BASE_URL}/search/tv?api_key=#{API_KEY}&query=#{searchable_query(series_name)}"
        JSON.parse(open(url).read, symbolize_names: true)&.dig(:results)
      end

      def get_parsed_multi_search_results(query)
        url = "#{BASE_URL}/search/multi?api_key=#{API_KEY}&query=#{searchable_query(query)}"
        JSON.parse(open(url).read, symbolize_names: true)&.dig(:results)
      end

      def url_for_person_search(person_name)
        "#{BASE_URL}/search/person?api_key=#{API_KEY}&query=#{searchable_query(person_name)}"
      end

      def get_parsed_movie_search_results(movie_title)
        url = "#{BASE_URL}/search/movie?api_key=#{API_KEY}&query=#{searchable_query(movie_title)}"
        JSON.parse(open(url).read, symbolize_names: true)&.dig(:results)
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
        # If a user searches for a name that starts with an `&` the api call fails.
        # This ensures no non alphanumeric characters make it into the query string.
        I18n.transliterate(query.gsub(/[^0-9a-z ]/i, ''))
      end

      def request_data_from_api(url)
        JSON.parse(open(url).read, symbolize_names: true)
      end
    end
  end
end
