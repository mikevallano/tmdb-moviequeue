module TmdbHandler
  BASE_URL = 'https://api.themoviedb.org/3'.freeze

  class TmdbHandlerError < StandardError
    def initialize(message)
      super(message)
    end
  end

  def tmdb_handler_search(query)
    @query = query.titlecase
    @search_url = "#{BASE_URL}/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @discover_results = @tmdb_response[:results]
    if !@discover_results.present?
      @not_found = "No results for '#{@query}'."
    else
      @movies = MovieSearch.parse_results(@discover_results)
    end
    rescue
      unless @tmdb_response.present?
        @not_found = "No results for '#{@query}.'"
      end
  end

  def tmdb_handler_movie_autocomplete(query)
    @search_url = "#{BASE_URL}/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @autocomplete_results = @tmdb_response[:results].map{ |result| result[:title] }.uniq
  end

  def tmdb_handler_person_autocomplete(query)
    @search_url = "#{BASE_URL}/search/multi?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @person_results = @tmdb_response[:results].select{ |result| result[:media_type] == "person"}
    @autocomplete_results = @person_results.map{ |result| result[:name] }.uniq
  end

  def tmdb_handler_movie_more(id)
    @movie_url = "#{BASE_URL}/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,similar,releases"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    @movie = MovieMore.parse_result(@result)

    @production_companies = @result[:production_companies]
    @similar_movies = @result[:similar][:results]
  end

  def tmdb_handler_similar_movies(tmdb_id, page)
    @movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases,similar&page=#{page}"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    @similar_results = @result[:similar][:results]
    @total_pages = @result[:similar][:total_pages]

    @movie = MovieMore.parse_result(@result)
    @movies = MovieSearch.parse_results(@similar_results)

    @page = page.to_i
    if @page > 1
      @previous_page = @page - 1
    end
    unless @page >= @total_pages
      @next_page = @page + 1
    end

  end #similar movies

  def tmdb_handler_full_cast(tmdb_id)
    @movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    tmdb_handler_movie_more(tmdb_id)
    @credits = @result[:credits]
    @cast = @result[:credits][:cast]
    @actors = MovieCast.parse_results(@cast)
    @crew = @result[:credits][:crew]
    @director_credits = @crew.select { |crew| crew[:job] == "Director" }
    @directors = MovieDirecting.parse_results(@director_credits)
    @editor_credits = @crew.select { |crew| crew[:job] == "Editor" }
    @editors = MovieEditing.parse_results(@editor_credits)
  end #full_cast

  def tmdb_handler_add_movie(tmdb_id)
    tmdb_handler_movie_more(tmdb_id)

    Movie.create(title: @movie.title, tmdb_id: @movie.tmdb_id, imdb_id: @movie.imdb_id,
    genres: @movie.genres, actors: @movie.actors, adult: @result[:adult], backdrop_path: @movie.backdrop_path,
    poster_path: @movie.poster_path, release_date: @movie.release_date, overview: @movie.overview, trailer: @movie.trailer,
    director: @movie.director, director_id: @movie.director_id, vote_average: @movie.vote_average,
    popularity: @movie.popularity, runtime: @movie.runtime, mpaa_rating: @movie.mpaa_rating)
  end

  def self.tmdb_handler_update_movie(movie)
    tmdb_id = movie.tmdb_id.to_s
    movie_url = "#{BASE_URL}/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,similar,releases"
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

  def tmdb_handler_actor_more(actor_id)
    tmdb_handler_person_detail_search(actor_id)
  end

  def tmdb_handler_person_detail_search(person_id)
    api_bio_url = "#{BASE_URL}/person/#{person_id}?api_key=#{ENV['tmdb_api_key']}"
    bio_results = JSON.parse(open(api_bio_url).read, symbolize_names: true)
    @person_profile = MoviePersonProfile.parse_result(bio_results)

    api_movie_credits_url = "#{BASE_URL}/person/#{person_id}/movie_credits?api_key=#{ENV['tmdb_api_key']}"
    movie_credits_results = JSON.parse(open(api_movie_credits_url).read, symbolize_names: true)
    @person_movie_credits = MoviePersonCredits.parse_result(movie_credits_results)

    api_tv_credits_url = "#{BASE_URL}/person/#{person_id}/tv_credits?api_key=#{ENV['tmdb_api_key']}"
    tv_credits_results = JSON.parse(open(api_tv_credits_url).read, symbolize_names: true)
    @person_tv_credits = TVPersonCredits.parse_result(tv_credits_results)
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
    show_results = JSON.parse(open(show_url).read, symbolize_names: true)
    TVSeries.parse_results(show_results, show_id)
  end

  def tmdb_handler_tv_season(series:, show_id:, season_number:)
    season_url = "#{BASE_URL}/tv/#{show_id}/season/#{season_number}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    season_results = JSON.parse(open(season_url).read, symbolize_names: true)
    TVSeason.parse_data(
      series: series,
      show_id: show_id,
      season_data: season_results
    )
  end

  def tmdb_handler_two_movie_search(movie_one, movie_two)
    tmdb_handler_search(movie_one)
      if @movies.present?
        @movie_one_id = @movies.first.tmdb_id
      else
        @not_found
      end
    tmdb_handler_search(movie_two)
      if @movies.present?
        @movie_two_id = @movies.first.tmdb_id
      else
        @not_found
      end

    unless @not_found.present?
      tmdb_handler_movie_more(@movie_one_id)
        @movie_one = @movie
        @movie_one_actors = @movie.actors
      tmdb_handler_movie_more(@movie_two_id)
        @movie_two = @movie
        @movie_two_actors = @movie.actors

      @common_actors = @movie_one_actors & @movie_two_actors
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
