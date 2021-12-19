module TvSeriesHelper

  def image_for_tv_poster(series)
    title = series.show_name
    if series.poster_path.present?
      image_tag("http://image.tmdb.org/t/p/w185#{series.poster_path}", title: title, alt: title)
    else
      render "shared/missing_poster", title: title
    end
  end
end
