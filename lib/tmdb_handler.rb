# frozen_string_literal: true

module TmdbHandler
  BASE_URL = 'https://api.themoviedb.org/3'.freeze

  class TmdbHandlerError < StandardError
    def initialize(message)
      super(message)
    end
  end

  def tmdb_handler_search(movie_title)
    query = I18n.transliterate(movie_title).titlecase
    search_url = "#{BASE_URL}/search/movie?query=#{movie_title}&api_key=#{ENV['tmdb_api_key']}"
    tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
    discover_results = tmdb_response[:results]
    not_found = "No results for '#{query}'." if tmdb_response.blank? || discover_results.blank?
    movies = MovieSearch.parse_results(discover_results) if discover_results.present?

    OpenStruct.new(
      movie_title: movie_title,
      not_found_message: not_found,
      query: query,
      movies: movies
    )
  end

  def tmdb_handler_movie_autocomplete(query)
    search_url = "#{BASE_URL}/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
    tmdb_response[:results].map{ |result| result[:title] }.uniq
  end

  def tmdb_handler_person_autocomplete(query)
    search_url = "#{BASE_URL}/search/multi?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
    person_results = tmdb_response[:results].select{ |result| result[:media_type] == "person"}
    person_results.map{ |result| result[:name] }.uniq
  end

  def tmdb_handler_movie_more(id)
    movie_url = "#{BASE_URL}/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases"
    result = JSON.parse(open(movie_url).read, symbolize_names: true)
    MovieMore.parse_result(result)
  end

  def tmdb_handler_full_cast(tmdb_id)
    movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    result = JSON.parse(open(movie_url).read, symbolize_names: true)
    director_credits = result[:credits][:crew].select { |crew| crew[:job] == "Director" }
    editor_credits = result[:credits][:crew].select { |crew| crew[:job] == "Editor" }

    OpenStruct.new(
      movie: tmdb_handler_movie_more(tmdb_id),
      actors: MovieCast.parse_results(result[:credits][:cast]),
      directors: MovieDirecting.parse_results(director_credits),
      editors: MovieEditing.parse_results(editor_credits),
    )
  end

  def tmdb_handler_add_movie(tmdb_id)
    movie = tmdb_handler_movie_more(tmdb_id)
    Movie.create(
      title: movie.title,
      tmdb_id: movie.tmdb_id,
      imdb_id: movie.imdb_id,
      genres: movie.genres,
      actors: movie.actors,
      adult: movie.adult,
      backdrop_path: movie.backdrop_path,
      poster_path: movie.poster_path,
      release_date: movie.release_date,
      overview: movie.overview,
      trailer: movie.trailer,
      director: movie.director,
      director_id: movie.director_id,
      vote_average: movie.vote_average,
      popularity: movie.popularity,
      runtime: movie.runtime,
      mpaa_rating: movie.mpaa_rating
    )
  end

  def self.tmdb_handler_update_movie(movie)
    tmdb_id = movie.tmdb_id.to_s
    movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases"
    api_result = HTTParty.get(movie_url).deep_symbolize_keys rescue nil
    raise TmdbHandlerError.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}") unless api_result
    if api_result[:status_code] == 34 && api_result[:status_message]&.include?('could not be found')
      puts "Movie not found, so not updated. Title: #{movie.title}. tmdb_id: #{tmdb_id}"
      return
    elsif api_result[:id]&.to_s != tmdb_id
      raise TmdbHandlerError.new("API request failed for movie: #{movie.title}. tmdb_id: #{tmdb_id}")
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
    raise TmdbHandlerError.new("#{movie.title} failed update. #{error.message}")
  end

  def tmdb_handler_person_detail_search(person_id)
    api_bio_url = "#{BASE_URL}/person/#{person_id}?api_key=#{ENV['tmdb_api_key']}"
    bio_results = JSON.parse(open(api_bio_url).read, symbolize_names: true)

    api_movie_credits_url = "#{BASE_URL}/person/#{person_id}/movie_credits?api_key=#{ENV['tmdb_api_key']}"
    movie_credits_results = JSON.parse(open(api_movie_credits_url).read, symbolize_names: true)

    api_tv_credits_url = "#{BASE_URL}/person/#{person_id}/tv_credits?api_key=#{ENV['tmdb_api_key']}"
    tv_credits_results = JSON.parse(open(api_tv_credits_url).read, symbolize_names: true)

    OpenStruct.new(
      person_id: person_id,
      profile: MoviePersonProfile.parse_result(bio_results),
      movie_credits: MoviePersonCredits.parse_result(movie_credits_results),
      tv_credits: TVPersonCredits.parse_result(tv_credits_results)
    )
  end

  def tmdb_handler_actor_credit(credit_id)
    credit_url = "#{BASE_URL}/credit/#{credit_id}?api_key=#{ENV['tmdb_api_key']}"
    credit_data = JSON.parse(open(credit_url).read, symbolize_names: true)
    TVActorCredit.parse_record(credit_data)
  end

  def tmdb_handler_tv_series_search(query)
    search_url = "#{BASE_URL}/search/tv?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
    discover_results = tmdb_response[:results]
    TVSeries.parse_search_records(discover_results) if discover_results.present?
  end

  def tmdb_handler_tv_series_autocomplete(query)
    search_url = "#{BASE_URL}/search/tv?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    tmdb_response = JSON.parse(open(search_url).read, symbolize_names: true)
    tmdb_response[:results].map{ |result| result[:name] }.uniq
  end

  def tmdb_handler_tv_series(show_id)
    show_url = "#{BASE_URL}/tv/#{show_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    series_data = JSON.parse(open(show_url).read, symbolize_names: true)
    TVSeries.parse_record(series_data, show_id)
  end

  def tmdb_handler_tv_season(series:, show_id:, season_number:)
    season_url = "#{BASE_URL}/tv/#{show_id}/season/#{season_number}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    season_results = JSON.parse(open(season_url).read, symbolize_names: true)
    TVSeason.parse_record(
      series: series,
      show_id: show_id,
      season_data: season_results
    )
  end

  def tmdb_handler_tv_episode(show_id:, season_number:, episode_number:)
    episode_url = "#{BASE_URL}/tv/#{show_id}/season/#{season_number}/episode/#{episode_number}?api_key=#{ENV['tmdb_api_key']}"
    episode_data = JSON.parse(open(episode_url).read, symbolize_names: true)
    TVEpisode.parse_record(episode_data)
  end

  def tmdb_handler_search_common_actors_in_two_movies(movie_one_title, movie_two_title)
    movie_one_results = tmdb_handler_search(movie_one_title)
    movie_two_results = tmdb_handler_search(movie_two_title)
    not_found_message = movie_one_results.not_found_message.presence || movie_two_results.not_found_message.presence

    if not_found_message.present?
      OpenStruct.new(not_found_message: not_found_message)
    else
      movie_one = tmdb_handler_movie_more(movie_one_results.movies.first.tmdb_id)
      movie_two = tmdb_handler_movie_more(movie_two_results.movies.first.tmdb_id)
      OpenStruct.new(
        movie_one: movie_one,
        movie_two: movie_two,
        common_actors: movie_one.actors & movie_two.actors,
        not_found_message: nil
      )
    end
  end
end
