module MoviesHelper

  def image_for(movie)
    if movie.poster_path.present?
      image_tag("http://image.tmdb.org/t/p/w185#{movie.poster_path}")
    else
      image_tag('placeholder.png')
    end #if
  end #image_for

  def link_to_movie(movie)
    if movie.in_db
      movie_path(movie)
    else
      movie_more_path(tmdb_id: movie.tmdb_id)
    end
  end

end #MoviesHelper
