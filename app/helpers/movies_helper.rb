module MoviesHelper

  def image_for(movie)
    if movie.poster_path.present?
      image_tag("http://image.tmdb.org/t/p/w185#{movie.poster_path}")
    else
      render "movies/movie_missing_poster", movie: movie
      # image_tag('placeholder.png')
    end #if
  end #image_for

  def link_to_movie(movie)
    if movie.in_db
      movie_path(movie)
    else
      movie_more_path(tmdb_id: movie.tmdb_id)
    end
  end

  def trailer_placeholder_text(movie)
    change_or_add = movie.trailer.present? ? 'change the' : 'add a'
    "To #{change_or_add} trailer, enter the YouTube URL"
  end

  def trailer_button_text(movie)
    movie.trailer.present? ? 'Change trailer' : 'Add a trailer'
  end

  def movie_stats(movie)
    "#{movie.release_date.stamp("2001") if movie.release_date.present?} | #{movie.mpaa_rating} | ★ #{movie.vote_average} /10 | #{movie.runtime}"
  end

end #MoviesHelper
