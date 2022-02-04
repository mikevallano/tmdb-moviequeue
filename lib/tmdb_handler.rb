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

  def tmdb_handler_movie_more(id)
    movie_url = "#{BASE_URL}/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases"
    result = JSON.parse(open(movie_url).read, symbolize_names: true)
    MovieMore.parse_result(result)
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

  def tmdb_handler_full_cast(tmdb_id)
    search_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    data = JSON.parse(open(search_url).read, symbolize_names: true)
    director_credits = data[:credits][:crew].select { |crew| crew[:job] == "Director" }
    editor_credits = data[:credits][:crew].select { |crew| crew[:job] == "Editor" }

    OpenStruct.new(
      movie: tmdb_handler_movie_more(tmdb_id),
      actors: MovieCast.parse_results(data[:credits][:cast]),
      directors: MovieDirecting.parse_results(director_credits),
      editors: MovieEditing.parse_results(editor_credits),
    )
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

  def tmdb_handler_discover_search(params)
    @actor = params[:actor]
    @actor2 = params[:actor2]
    @exact_year = params[:exact_year]
    @after_year = params[:after_year]
    @before_year = params[:before_year]
    @genre = params[:genre]
    @company = params[:company]
    @mpaa_rating = params[:mpaa_rating]
    @sort_by = params[:sort_by]
    @page = params[:page]
    @year_select = params[:year_select]

    if @actor.present?
      @actor1_url = "#{BASE_URL}/search/person?query=#{@actor}&api_key=#{ENV['tmdb_api_key']}"
      @actor1_search_result = JSON.parse(open(@actor1_url).read, symbolize_names: true)[:results]
      if !@actor1_search_result.present?
        return @not_found = "No results for '#{actor}'."
      else
        @actor1_id = @actor1_search_result.first[:id]
      end
    end

    if @actor2.present?
      @actor2_url = "#{BASE_URL}/search/person?query=#{@actor2}&api_key=#{ENV['tmdb_api_key']}"
      @actor2_search_result = JSON.parse(open(@actor2_url).read, symbolize_names: true)[:results]
      if !@actor2_search_result.present?
        return @not_found = "No results for '#{actor2}'."
      else
        @actor2_id = @actor2_search_result.first[:id]
      end
    end

    if @actor1_id.present? && @actor2_id.present?
      @people = "#{@actor1_id}, #{@actor2_id}"
    elsif @actor1_id.present?
      @people = @actor1_id
    elsif @actor2_id.present?
      @people = @actor_2_id
    else
      @people = ''
    end

    years = [@exact_year, @after_year, @before_year].compact
    if years.any?
      years = years.first
      if years == @exact_year
        @year_search = "primary_release_year=#{years}"
      elsif years == @after_year
        @year_search = "primary_release_date.gte=#{years}"
      else
        @year_search = "primary_release_date.lte=#{years}"
      end
    else
      @year_search = "primary_release_date.gte=1800-01-01"
    end
    @discover_url = "#{BASE_URL}/discover/movie?#{@year_search}&with_genres=#{@genre}&with_people=#{@people}&with_companies=#{@company}&certification_country=US&certification=#{@mpaa_rating}&sort_by=#{@sort_by}.desc&page=#{@page}&api_key=#{ENV['tmdb_api_key']}"
    @discover_results = JSON.parse(open(@discover_url).read, symbolize_names: true)[:results]
    @movies = MovieSearch.parse_results(@discover_results)
    @total_pages = JSON.parse(open(@discover_url).read, symbolize_names: true)[:total_pages]

    @page = @page.to_i
    if @page > 1
      @previous_page = @page - 1
    end
    unless @page >= @total_pages
      @next_page = @page + 1
    end

    rescue
    if @actor.present?
      unless @actor1_search_result.present?
        @not_found = "No results for '#{@actor}'."
      end
    end
    if @actor2.present?
      unless @actor2_search_result.present?
        @not_found = "No results for '#{@actor2}'."
      end
    end

  end #discover search
end
