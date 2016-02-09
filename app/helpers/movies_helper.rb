module MoviesHelper

  def image_for(movie)
    if movie.poster_path.present?
      image_tag("http://image.tmdb.org/t/p/w185#{movie.poster_path}")
    else
      image_tag('placeholder.png')
    end #if
  end #image_for

end #MoviesHelper
