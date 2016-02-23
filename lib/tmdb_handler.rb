module TmdbHandler

  def tmdb_handler_search(query)
    @query = query.titlecase
    @search_url = "http://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
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
    @search_url = "http://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @autocomplete_results = @tmdb_response[:results].map{ |result| result[:title] }
  end

  def tmdb_handler_person_autocomplete(query)
    @search_url = "http://api.themoviedb.org/3/search/multi?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @person_results = @tmdb_response[:results].select{ |result| result[:media_type] == "person"}
    @autocomplete_results = @person_results.map{ |result| result[:name] }
  end

  def tmdb_handler_movie_more(id)
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,similar,releases"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    @movie = MovieMore.parse_result(@result)

    @production_companies = @result[:production_companies]
    @similar_movies = @result[:similar][:results]
  end

  def tmdb_handler_similar_movies(tmdb_id, page)
    @movie_url = "https://api.themoviedb.org/3/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,releases,similar&page=#{page}"
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
    @movie_url = "https://api.themoviedb.org/3/movie/#{tmdb_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
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
    # TODO : add these in if it makes sense
    @writer_credits = @crew.select { |crew| crew[:job] == "Writer" }
    @screenplay_credits = @crew.select { |crew| crew[:job] == "Screenplay" }
    @producer_credits = @crew.select { |crew| crew[:job] == "Producer" }
  end #full_cast

  def tmdb_handler_add_movie(tmdb_id)
    tmdb_handler_movie_more(tmdb_id)

    Movie.create(title: @movie.title, tmdb_id: @movie.tmdb_id, imdb_id: @movie.imdb_id,
    genres: @movie.genres, actors: @movie.actors, adult: @result[:adult], backdrop_path: @movie.backdrop_path,
    poster_path: @movie.poster_path, release_date: @movie.release_date, overview: @movie.overview, trailer: @movie.trailer,
    director: @movie.director, director_id: @movie.director_id, vote_average: @movie.vote_average,
    popularity: @movie.popularity, runtime: @movie.runtime, mpaa_rating: @movie.mpaa_rating)
  end

  def tmdb_handler_actor_more(actor_id)
    @bio_url = "https://api.themoviedb.org/3/person/#{actor_id}?api_key=#{ENV['tmdb_api_key']}"
    @bio_results = JSON.parse(open(@bio_url).read, symbolize_names: true)
    @name = @bio_results[:name]
    @bio = @bio_results[:biography]
    @birthday = Date.parse(@bio_results[:birthday]) if @bio_results[:birthday].present?
    @profile_path = @bio_results[:profile_path]

    @credits_url = "https://api.themoviedb.org/3/person/#{actor_id}/combined_credits?api_key=#{ENV['tmdb_api_key']}"
    @credits_results = JSON.parse(open(@credits_url).read, symbolize_names: true)
    @movie_credits = @credits_results[:cast].select { |cast| cast[:media_type] == "movie" }
    @tv_credits = @credits_results[:cast].select { |cast| cast[:media_type] == "tv" }

    @director_credits = @credits_results[:crew].select { |crew| crew[:job] == "Director" }
    @editor_credits = @credits_results[:crew].select { |crew| crew[:job] == "Editor" }
    @writer_credits = @credits_results[:crew ].select { |crew| crew[:job] == "Writer" }
    @screenplay_credits = @credits_results[:crew].select { |crew| crew[:job] == "Screenplay" }
    @producer_credits = @credits_results[:crew].select { |crew| crew[:job] == "Producer" }
  end

  def tmdb_handler_person_detail_search(person_id)
    @bio_url = "https://api.themoviedb.org/3/person/#{person_id}?api_key=#{ENV['tmdb_api_key']}"
    @bio_results = JSON.parse(open(@bio_url).read, symbolize_names: true)
    @person_bio = MoviePersonBio.parse_result(@bio_results)

    @credits_url = "https://api.themoviedb.org/3/person/#{person_id}/movie_credits?api_key=#{ENV['tmdb_api_key']}"
    @credits_results = JSON.parse(open(@credits_url).read, symbolize_names: true)

    @person_credits = MoviePersonCredits.parse_result(@credits_results)
  end

  def tmdb_handler_actor_credit(credit_id)
    @credit_url = "https://api.themoviedb.org/3/credit/#{credit_id}?api_key=#{ENV['tmdb_api_key']}"
    @credit_results = JSON.parse(open(@credit_url).read, symbolize_names: true)
    @character = @credit_results[:media][:character]
    @show_id = @credit_results[:media][:id]
    if @credit_results[:media][:episodes].present?
      @air_date = @credit_results[:media][:episodes].first[:air_date]
      @episode_name = @credit_results[:media][:episodes].first[:name]
      @season_number = @credit_results[:media][:episodes].first[:season_number]
      @episode_number = @credit_results[:media][:episodes].first[:episode_number]
      @episode_overview = @credit_results[:media][:episodes].first[:overview]
      @still_image = @credit_results[:media][:episodes].first[:still_path]
      @episode_url = "https://api.themoviedb.org/3/tv/#{@episode_id}/season/#{@season_number}/episode/#{@episode_number}?api_key=#{ENV['tmdb_api_key']}"
    else
      @seasons = @credit_results[:media][:seasons]
    end
  end

  def tmdb_handler_tv_more(show_id)
    @show_url = "https://api.themoviedb.org/3/tv/#{show_id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    @show_results = JSON.parse(open(@show_url).read, symbolize_names: true)
    @first_air_date = @show_results[:first_air_date]
    @last_air_date = @show_results[:last_air_date]
    @show_id = show_id
    @show_name = @show_results[:name]
    @backdrop_path = @show_results[:backdrop_path]
    @poster_path = @show_results[:poster_path]
    @number_of_episodes = @show_results[:number_of_episodes]
    @number_of_seasons = @show_results[:number_of_seasons]
    @overview = @show_results[:overview]
    @seasons = @show_results[:seasons]
    @show_cast = @show_results[:credits][:cast]
  end

  def tmdb_handler_tv_season(show_id, season_number)
    @season_url = "https://api.themoviedb.org/3/tv/#{show_id}/season/#{season_number}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    @season_results = JSON.parse(open(@season_url).read, symbolize_names: true)
    tmdb_handler_tv_more(show_id)
    @episodes = @season_results[:episodes]
    @season_cast = @season_results[:credits][:cast]
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

  def tmdb_handler_discover_search(exact_year, after_year, before_year, genre, actor, actor2,
    company, mpaa_rating, sort_by, page)

    if actor.present?
      @actor1_url = "https://api.themoviedb.org/3/search/person?query=#{actor}&api_key=#{ENV['tmdb_api_key']}"
      @actor1_search_result = JSON.parse(open(@actor1_url).read, symbolize_names: true)[:results]
      @actor1_search_result.present? ? @actor1_id = @actor1_search_result.first[:id] : @not_found = "No results for '#{actor}'."
    end
    if actor2.present?
      @actor2_url = "https://api.themoviedb.org/3/search/person?query=#{actor2}&api_key=#{ENV['tmdb_api_key']}"
      @actor2_search_result = JSON.parse(open(@actor2_url).read, symbolize_names: true)[:results]
      @actor2_search_result.present? ? @actor2_id = @actor2_search_result.first[:id] : @not_found = "No results for '#{actor2}'."
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
    years = [exact_year, after_year, before_year].compact
    if years.any?
      years = years.first
      if years == exact_year
        @year_search = "primary_release_year=#{years}"
      elsif years == after_year
        @year_search = "primary_release_date.gte=#{years}"
      else
        @year_search = "primary_release_date.lte=#{years}"
      end
    else
      @year_search = "primary_release_date.gte=1800-01-01"
    end

    @discover_url = "https://api.themoviedb.org/3/discover/movie?#{@year_search}&with_genres=#{genre}&with_people=#{@people}&with_companies=#{company}&certification_country=US&certification=#{mpaa_rating}&sort_by=#{sort_by}.desc&page=#{@page}&api_key=#{ENV['tmdb_api_key']}"
    @discover_results = JSON.parse(open(@discover_url).read, symbolize_names: true)[:results]
    @movies = MovieSearch.parse_results(@discover_results)
    @total_pages = JSON.parse(open(@discover_url).read, symbolize_names: true)[:total_pages]

    @page = page.to_i
    if @page > 1
      @previous_page = @page - 1
    end
    unless @page >= @total_pages
      @next_page = @page + 1
    end

    rescue
    if actor.present?
      unless @actor1_search_result.present?
        @not_found = "No results for '#{actor}'."
      end
    end
    if actor2.present?
      unless @actor2_search_result.present?
        @not_found = "No results for '#{actor2}'."
      end
    end

  end #discover search


end