# frozen_string_literal: true

module TVSeriesHelper
  def image_for_tv_poster(series)
    title = series.show_name
    if series.poster_path.present?
      image_tag(
        TmdbImageService.image_url(file_path: series.poster_path, size: :medium, image_type: :poster),
        title: title,
        alt: title
      )
    else
      render 'shared/missing_poster', title: title
    end
  end

  def formatted_season_number(season_number)
    # to display the correct current season number in the view:
    if season_number == '0'
       'Misc/Extras'
    else
      "Season #{season_number}"
    end
  end
end
