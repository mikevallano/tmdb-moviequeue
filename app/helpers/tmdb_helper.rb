# frozen_string_literal: true

module TmdbHelper
  def headshot_for(actor)
    if actor.profile_path.present?
      image_tag(TmdbImageService.image_url(
                  file_path: actor.profile_path,
                  size: :medium,
                  image_type: :profile
                ))
    else
      image_tag('headshot_placeholder.jpg')
    end
  end

  def season_number_display(season)
    season.zero? ? 'Misc/Extras' : season
  end
end
