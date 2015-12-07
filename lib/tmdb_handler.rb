module TmdbHandler

  def tmdb_handler_search(query)
    @search_url = "http://api.themoviedb.org/3/search/movie?query=#{query}&api_key=#{ENV['tmdb_api_key']}"
    @tmdb_response = JSON.parse(open(@search_url).read, symbolize_names: true)
    @results = @tmdb_response[:results]
  end

  def tmdb_handler_movie_info(id)
    @movie_url = "https://api.themoviedb.org/3/movie/#{id}?api_key=#{ENV['tmdb_api_key']}&append_to_response=trailers"
    @result = JSON.parse(open(@movie_url).read, symbolize_names: true)
  end

  def tmdb_handler_add_movie(id)
    tmdb_handler_movie_info(id)
    Movie.create(title: @result[:title], tmdb_id: @result[:id], imdb_id: @result[:imdb_id])
  end

end