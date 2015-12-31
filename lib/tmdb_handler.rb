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
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
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
      @id = @actor_search_result.first[:id]
      @search_id_url = "https://api.themoviedb.org/3/discover/movie?with_cast=#{@id}&page=#{@page}&sort_by=popularity.desc&api_key=#{ENV['tmdb_api_key']}"
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