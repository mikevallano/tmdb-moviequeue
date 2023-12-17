# frozen_string_literal: true

module MoviesHelper
  def image_for(movie)
    if movie.poster_path.present?
      image_tag(
        TmdbImageService.image_url(file_path: movie.poster_path, size: :medium, image_type: :poster),
        title: movie.title,
        alt: movie.title
      )
    else
      render "shared/missing_poster", title: movie.title
    end
  end

  def display_actor_age_at_release(actor_birthday, release_year)
    age = actor_age_at_movie_release(actor_birthday, release_year)
    "| age #{age}" if age.present?
  end

  def actor_age_at_movie_release(actor_birthday, release_year)
    return nil unless actor_birthday.to_date.present? && release_year != "Date unavailable"

    birth_year = actor_birthday.to_date.year
    release_year.to_i - birth_year
  end

  def link_to_movie(movie)
    if movie.in_db
      movie_path(movie)
    else
      movie_more_path(tmdb_id: movie.tmdb_id)
    end
  end

  def trailer_placeholder_text(movie)
    change_or_add = movie.trailer.present? ? 'Change' : 'Add'
    "Enter YouTube URL to #{change_or_add} Trailer"
  end

  def trailer_button_text(movie)
    movie.trailer.present? ? 'Change' : '+ Add'
  end

  def movie_stats_display(movie)
    movie_stats = [
      release_date_display(movie),
      movie.mpaa_rating,
      runtime_display(movie),
      star_rating(movie)
    ]
    movie_stats.compact.join(" | ")
  end

  def movie_genres_display(movie)
    output = raw(movie.genres.map do |genre|
      link_to genre, genre_path(genre)
    end.join(", "))
    output.prepend(" | ")
  end

  def display_pay_model_icon(movie_pay_model)
    case movie_pay_model
      when 'try' then 'search_check'
      when 'free' then 'emoji_emotions'
      when 'rent' then 'paid'
      when 'buy' then 'shopping_bag'
    end
  end

  def firstify_number(number)
    if number.to_s[-2..-1] == '11'
      "#{number}th"
    elsif number.to_s[-1] == '1'
      "#{number}st"
    elsif number.to_s[-2..-1] == '12'
      "#{number}th"
    elsif number.to_s[-1] == '2'
      "#{number}nd"
    elsif number.to_s[-2..-1] == '13'
      "#{number}th"
    elsif number.to_s[-1] == '3'
      "#{number}rd"
    else
    "#{number}th"
    end
  end

  def movie_cast_display(movie, qty)
    cast = movie_actors_display(movie, qty)
    cast += movie_director_display(movie)
    cast += full_cast_link(movie)
  end

  # TODO: This is not used since we're not using autocomplete
  # on add to list functionality. Keeping in case we want to use in the future.
  def list_autocomplete_dropdown(movie)
    current_user.lists_except_movie(movie)
      .map{ |list| {label: list.name, id: list.id} }
  end

  def list_add_dropdown(movie)
    current_user.lists_except_movie(movie)
      .map{ |list| [list.name, list.id] }
  end


  private

  def movie_actors_display(movie, qty)
    raw(movie.actors.first(qty).map do |actor|
      link_to actor, actor_search_path(actor: I18n.transliterate(actor)), class: 'cast-name-link', data: {turbo: false}
    end.join(""))
  end

  def movie_director_display(movie)
    link_to "#{movie.director} (director)", director_search_path(director_id: movie.director_id, name: I18n.transliterate(movie.director)), class: 'cast-name-link' if movie.director.present?
  end

  def full_cast_link(movie)
    link_to '<i class="fa fa-chevron-circle-right"></i> Full Cast'.html_safe, full_cast_path(tmdb_id: movie.tmdb_id), id: "full_cast_link_movie_show", data: {turbo_frame: '_top', turbo: false}
  end

  def runtime_display(movie)
    movie.runtime.present? ? DateAndTimeHelper.display_time(movie.runtime) : nil
  end

  def release_date_display(movie)
    movie.release_date.stamp("2001") if movie.release_date.present?
  end

  def star_rating(movie)
    if current_user.rated_movies.include?(movie)
      "IMDB: #{movie.vote_average} ★, Me: #{movie.ratings.by_user(current_user).first.value } ♥"
    else
      "#{movie.vote_average} ★"
    end
  end
end #MoviesHelper
