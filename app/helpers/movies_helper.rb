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

  def movie_stats_display(movie)
    "#{release_date_display(movie)} | #{movie.mpaa_rating} | #{runtime_display(movie)} | #{star_rating(movie)}"
  end

  def movie_genres_display(movie)
    output = raw(movie.genres.map do |genre|
      link_to genre, genre_path(genre)
    end.join(", "))
    output.prepend(" | ")
  end

  def movie_cast_display(movie)
    cast = movie_actors_display(movie)
    cast += movie_director_display(movie)
    cast += full_cast_link(movie)
  end


  private

  def movie_actors_display(movie)
    raw(movie.actors.first(4).map do |actor|
      link_to actor, actor_search_path(actor: I18n.transliterate(actor)), class: 'tag-link'
    end.join(""))
  end

  def movie_director_display(movie)
    link_to "#{movie.director} (director)", director_search_path(director_id: movie.director_id, name: I18n.transliterate(movie.director)), class: 'tag-link' if movie.director.present?
  end

  def full_cast_link(movie)
    link_to '<i class="fa fa-chevron-circle-right"></i> Full Cast'.html_safe, full_cast_path(tmdb_id: movie.tmdb_id), id: "full_cast_link_movie_show"
  end

  def runtime_display(movie)
    "#{movie.runtime/60}hr #{movie.runtime % 60}min"
  end

  def release_date_display(movie)
    movie.release_date.stamp("2001") if movie.release_date.present?
  end

  def star_rating(movie)
    if current_user.rated_movies.include?(movie)
      "IMDB: #{movie.vote_average} ★, Me: #{movie.ratings.by_user(current_user).first.value } ★"
    else
      "#{movie.vote_average} ★"
    end
  end

end #MoviesHelper
