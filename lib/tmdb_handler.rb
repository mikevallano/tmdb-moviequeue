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
    Movie.create(title: @result[:title], tmdb_id: @result[:id], imdb_id: @result[:imdb_id], genres: @genres,
      actors: @actors, adult: @result[:adult], backdrop_path: @result[:backdrop_path],
      poster_path: @result[:poster_path], release_date: @result[:release_date],
      overview: @result[:overview], trailer: @result[:trailers][:youtube][0][:source],
      vote_average: @result[:vote_average], popularity: @result[:popularity], runtime: @result[:runtime] )
  end

end