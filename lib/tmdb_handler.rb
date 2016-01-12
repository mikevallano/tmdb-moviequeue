module TmdbHandler

  def tmdb_handler_search(query)
    @search_url = "http://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @results = @tmdb_response[:results]
    rescue
      unless @tmdb_response.present?
        @results = []
      end
  end

  def tmdb_handler_movie_info(id)
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,similar,releases"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    @tmdb_id = @result[:id]
    @movie = Movie.find_by(tmdb_id: @tmdb_id)
    @title = @result[:title]
    @release_date = @result[:release_date]
    @vote_average = @result[:vote_average]
    @genre_list = @result[:genres]
    @overview = @result[:overview]
    @cast = @result[:credits][:cast]
    @youtube_trailers = @result[:trailers][:youtube]
    @trailer_url = @result[:trailers][:youtube][0][:source] if @youtube_trailers.present?
    @mpaa_rating = @result[:releases][:countries].select { |country| country[:iso_3166_1] == "US" }.first[:certification]

    @crew = @result[:credits][:crew]
    @crew.find do |crew|
      if crew[:department] == "Directing"
        @director = crew[:name]
        @director_id = crew[:id]
      end
    end

    @production_companies = @result[:production_companies]

    @similar = @result[:similar][:results]
  end

  def tmdb_handler_add_movie(id)
    tmdb_handler_movie_info(id)
    @genres = @result[:genres].map { |genre| genre[:name]}
    @actors = @result[:credits][:cast].map { |cast| cast[:name] }
    @crew = @result[:credits][:crew]
    @crew.find do |crew|
      if crew[:department] == "Directing"
        @director = crew[:name]
        @director_id = crew[:id]
      end
    end
    @trailer = @result[:trailers][:youtube][0][:source] if @result[:trailers][:youtube].present?

    Movie.create(title: @result[:title], tmdb_id: @result[:id], imdb_id: @result[:imdb_id],
      genres: @genres, actors: @actors, adult: @result[:adult], backdrop_path: @result[:backdrop_path],
      poster_path: @result[:poster_path], release_date: @result[:release_date],
      overview: @result[:overview], trailer: @trailer, director: @director, director_id: @director_id,
      vote_average: @result[:vote_average], popularity: @result[:popularity], runtime: @result[:runtime],
      mpaa_rating: @mpaa_rating)
  end

  def tmdb_handler_actor_more(actor_id)
    @bio_url = "https://api.themoviedb.org/3/person/#{actor_id}?api_key=#{ENV['tmdb_api_key']}"
    @bio_results = JSON.parse(open(@bio_url).read, symbolize_names: true)
    @name = @bio_results[:name]
    @bio = @bio_results[:biography]
    @birthday = @bio_results[:birthday]
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
      if @results.present?
        @movie_one_id = @results.first[:id]
      else
        redirect_to :two_movie_search, notice: "No results for the first movie. Try again" and return
      end
    tmdb_handler_search(movie_two)
      if @results.present?
        @movie_two_id = @results.first[:id]
      else
        redirect_to :two_movie_search, notice: "No results for the second movie. Try again" and return
      end

    tmdb_handler_movie_info(@movie_one_id)
      @movie_one = @result
      @movie_one_cast = @cast
      @movie_one_cast_names = @cast.map { |cast| cast[:name] }
    tmdb_handler_movie_info(@movie_two_id)
      @movie_two = @result
      @movie_two_cast = @cast
      @movie_two_cast_names = @cast.map { |cast| cast[:name] }

    @common_actors = @movie_one_cast_names & @movie_two_cast_names

  end

  def tmdb_handler_director_search(id)
    @director_url = "https://api.themoviedb.org/3/person/#{id}/movie_credits?api_key=3fb5f9a5dbd80d943fdccf6bd1e7f188"
    @result = JSON.parse(open(@director_url).read, symbolize_names: true)

    @actor_credits = @result[:cast]
    @director_credits = @result[:crew].select { |crew| crew[:job] == "Director" }
    @editor_credits = @result[:crew].select { |crew| crew[:job] == "Editor" }
    @writer_credits = @result[:crew ].select { |crew| crew[:job] == "Writer" }
    @screenplay_credits = @result[:crew].select { |crew| crew[:job] == "Screenplay" }
    @producer_credits = @result[:crew].select { |crew| crew[:job] == "Producer" }
  end

  def tmdb_handler_discover_search(exact_year, after_year, before_year, genre, actor, actor2,
    company, mpaa_rating, sort_by, page)
    @page = page.to_i
    if actor.present?
      @actor1_url = "https://api.themoviedb.org/3/search/person?query=#{actor}&api_key=#{ENV['tmdb_api_key']}"
      @actor1_search_result = JSON.parse(open(@actor1_url).read, symbolize_names: true)[:results]
      @actor1_id = @actor1_search_result.first[:id] if @actor1_search_result.present?
    end
    if actor2.present?
      @actor2_url = "https://api.themoviedb.org/3/search/person?query=#{actor2}&api_key=#{ENV['tmdb_api_key']}"
      @actor2_search_result = JSON.parse(open(@actor2_url).read, symbolize_names: true)[:results]
      @actor2_id = @actor2_search_result.first[:id] if @actor2_search_result.present?
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
        @year_search = "release_date.gte=#{years}"
      else
        @year_search = "release_date.lte=#{years}"
      end
    else
      @year_search = "release_date.gte=1800-01-01"
    end

    @discover_url = "https://api.themoviedb.org/3/discover/movie?#{@year_search}&with_genres=#{genre}&with_people=#{@people}&with_companies=#{company}&certification_country=US&certification=#{mpaa_rating}&sort_by=#{sort_by}.desc&page=#{@page}&api_key=#{ENV['tmdb_api_key']}"
    @discover_results = JSON.parse(open(@discover_url).read, symbolize_names: true)[:results]
    @total_pages = JSON.parse(open(@discover_url).read, symbolize_names: true)[:total_pages]

    if @page > 1
      @previous_page = @page - 1
    end
    unless @page >= @total_pages
      @next_page = @page + 1
    end

    rescue
    if actor.present?
      unless @actor1_search_result.present?
        @discover_results = []
      end
    end
    if actor2.present?
      unless @actor2_search_result.present?
        @discover_results = []
      end
    end

  end #discover search

end