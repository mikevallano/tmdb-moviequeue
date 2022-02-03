# frozen_string_literal: true

module Tmdb
  class Client
    class Error < StandardError; end
    BASE_URL = 'https://api.themoviedb.org/3'.freeze

    class << self
      def movie_autocomplete(query)
        data = get_parsed_movie_search_results(query)
        data[:results].map{ |result| result[:title] }.uniq
      end

      def person_autocomplete(query)
        data = get_parsed_multi_search_results(query)
        person_results = data[:results].select{ |result| result[:media_type] == "person"}
        person_results.map{ |result| result[:name] }.uniq
      end

      # def get_full_cast(tmdb_id)
      #   search_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
      #   data = fetch_parsed_response(search_url)
      #   director_credits = data[:credits][:crew].select { |crew| crew[:job] == "Director" }
      #   editor_credits = data[:credits][:crew].select { |crew| crew[:job] == "Editor" }
      #
      #   OpenStruct.new(
      #     movie: tmdb_handler_movie_more(tmdb_id),
      #     actors: MovieCast.parse_results(data[:credits][:cast]),
      #     directors: MovieDirecting.parse_results(director_credits),
      #     editors: MovieEditing.parse_results(editor_credits),
      #   )
      # end

      def update_movie(movie)
        tmdb_id = movie.tmdb_id.to_s
        movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases"
        api_result = HTTParty.get(movie_url).deep_symbolize_keys rescue nil
        raise Error.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}") unless api_result
        if api_result[:status_code] == 34 && api_result[:status_message]&.include?('could not be found')
          puts "Movie not found, so not updated. Title: #{movie.title}. tmdb_id: #{tmdb_id}"
          return
        elsif api_result[:id]&.to_s != tmdb_id
          raise Error.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}")
        end

        updated_data = MovieMore.tmdb_info(api_result)

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

      private

      def get_parsed_credit(credit_id)
        search_url = "#{BASE_URL}/credit/#{credit_id}?api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end

      def get_parsed_person_bio(person_id)
        search_url = "#{BASE_URL}/person/#{person_id}?api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end

      def get_parsed_person_movie_credits(person_id)
        search_url = "#{BASE_URL}/person/#{person_id}/movie_credits?api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end

      def get_parsed_person_tv_credits(person_id)
        search_url = "#{BASE_URL}/person/#{person_id}/tv_credits?api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end

      def get_parsed_multi_search_results(query)
        search_url = "#{BASE_URL}/search/multi?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end

      def get_parsed_movie_search_results(query)
        search_url = "#{BASE_URL}/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
        JSON.parse(open(search_url).read, symbolize_names: true)
      end
    end
  end
end
