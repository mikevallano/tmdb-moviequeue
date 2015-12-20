module TmdbHandler

  def tmdb_handler_search(query)
    @search_url = "http://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @results = @tmdb_response[:results]
  end

  def tmdb_handler_movie_info(id)
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers,credits"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
  end

  def tmdb_handler_add_movie(id)
    tmdb_handler_movie_info(id)
    @genres = @result[:genres].map { |genre| genre[:name]}
    @actors = @result[:credits][:cast].map { |cast| cast[:name] }
    @trailer = @result[:trailers][:youtube][0][:source] if @result[:trailers][:youtube].present?
    Movie.create(title: @result[:title], tmdb_id: @result[:id], imdb_id: @result[:imdb_id], genres: @genres,
      actors: @actors, adult: @result[:adult], backdrop_path: @result[:backdrop_path],
      poster_path: @result[:poster_path], release_date: @result[:release_date],
      overview: @result[:overview], trailer: @trailer,
      vote_average: @result[:vote_average], popularity: @result[:popularity], runtime: @result[:runtime] )
  end

  def tmdb_handler_actor_search(name)
    @search_url = "https://api.themoviedb.org/3/search/person?query=#{name}&api_key=#{ENV['tmdb_api_key']}"
    @actor_search_result = JSON.parse(open(@search_url).read, symbolize_names: true)
    @results = @actor_search_result[:results]
    @id = @results.first[:id]
    @search_id_url = "https://api.themoviedb.org/3/discover/movie?with_cast=#{@id}&sort_by=popularity.desc&api_key=#{ENV['tmdb_api_key']}"
    # @search_id_url = "https://api.themoviedb.org/3/person/#{@id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    @actor_results = JSON.parse(open(@search_id_url).read, symbolize_names: true)
    @been_in = @actor_results[:results]
    # @been_in = @actor_results[:credits][:cast]
  end

  def tmdb_handler_two_actor_search(name_one, name_two)
    @search_url1 = "https://api.themoviedb.org/3/search/person?query=#{name_one}&api_key=#{ENV['tmdb_api_key']}"
    @search_url2 = "https://api.themoviedb.org/3/search/person?query=#{name_two}&api_key=#{ENV['tmdb_api_key']}"
    @actor_search_result1 = JSON.parse(open(@search_url1).read, symbolize_names: true)
    @actor_search_result2 = JSON.parse(open(@search_url2).read, symbolize_names: true)
    @results1 = @actor_search_result1[:results]
    @results2 = @actor_search_result2[:results]
    @id1 = @results1.first[:id]
    @id2 = @results2.first[:id]
    @search_ids_url = "https://api.themoviedb.org/3/discover/movie?with_people=#{@id1},#{@id2}&sort_by=popularity.desc&api_key=#{ENV['tmdb_api_key']}"
    # @search_id_url = "https://api.themoviedb.org/3/person/#{@id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=credits"
    @actor_results = JSON.parse(open(@search_ids_url).read, symbolize_names: true)
    @been_in = @actor_results[:results]
    # @been_in = @actor_results[:credits][:cast]
  end

end