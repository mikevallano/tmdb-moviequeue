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
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits,similar"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
    @similar = @result[:similar][:results]
    @crew = @result[:credits][:crew]
    @crew.find do |i|
      if i[:department] == "Directing"
        @director = i[:name]
        @director_id = i[:id]
      end
    end
  end

  def tmdb_handler_add_movie(id)
    tmdb_handler_movie_info(id)
    @genres = @result[:genres].map { |genre| genre[:name]}
    @actors = @result[:credits][:cast].map { |cast| cast[:name] }
    @crew = @result[:credits][:crew]
    @crew.find do |i|
      if i[:department] == "Directing"
        @director = i[:name]
        @director_id = i[:id]
      end
    end
    @trailer = @result[:trailers][:youtube][0][:source] if @result[:trailers][:youtube].present?

    Movie.create(title: @result[:title], tmdb_id: @result[:id], imdb_id: @result[:imdb_id],
      genres: @genres, actors: @actors, adult: @result[:adult], backdrop_path: @result[:backdrop_path],
      poster_path: @result[:poster_path], release_date: @result[:release_date],
      overview: @result[:overview], trailer: @trailer, director: @director, director_id: @director_id,
      vote_average: @result[:vote_average], popularity: @result[:popularity], runtime: @result[:runtime])
  end

  def tmdb_handler_actor_search(name, page)
    @page = page.to_i
    @search_url = "https://api.themoviedb.org/3/search/person?query=#{name}&api_key=#{ENV['tmdb_api_key']}"
     @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
     @actor_search_result = @tmdb_response[:results]
    if @actor_search_result.present?
      @actor_id = @actor_search_result.first[:id]
      @search_id_url = "https://api.themoviedb.org/3/discover/movie?with_cast=#{@actor_id}&page=#{@page}&sort_by=popularity.desc&api_key=#{ENV['tmdb_api_key']}"
      @been_in = JSON.parse(open(@search_id_url).read, symbolize_names: true)[:results]
      @total_pages = JSON.parse(open(@search_id_url).read, symbolize_names: true)[:total_pages]
      if @page > 1
        @previous_page = @page - 1
      end
      unless @page >= @total_pages
        @next_page = @page + 1
      end
    else
      @been_in = []
    end
    rescue
      unless @tmdb_response.present?
        @been_in = []
      end
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

  def tmdb_handler_two_actor_search(name_one, name_two)
    @search_url1 = "https://api.themoviedb.org/3/search/person?query=#{name_one}&api_key=#{ENV['tmdb_api_key']}"
    @search_url2 = "https://api.themoviedb.org/3/search/person?query=#{name_two}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response1 = JSON.parse(open(@search_url1).read, symbolize_names: true)
    @tmdb_response2 = JSON.parse(open(@search_url2).read, symbolize_names: true)
    @actor1_search_result = @tmdb_response1[:results]
    @actor2_search_result = @tmdb_response2[:results]
    if @actor1_search_result.present? && @actor2_search_result.present?
      @id1 = @actor1_search_result.first[:id]
      @id2 = @actor2_search_result.first[:id]
      @search_ids_url = "https://api.themoviedb.org/3/discover/movie?with_people=#{@id1},#{@id2}&sort_by=revenue.desc&api_key=#{ENV['tmdb_api_key']}"
      @been_in = JSON.parse(open(@search_ids_url).read, symbolize_names: true)[:results]
    else
      @been_in = []
    end
  rescue
    unless @tmdb_response1.present? && @tmdb_response2.present?
      @been_in = []
    end
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

end