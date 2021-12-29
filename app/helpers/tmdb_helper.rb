# frozen_string_literal: true

module TmdbHelper
  def headshot_for(actor)
    if actor.profile_path.present?
      image_tag(TmdbImageUrlHelper.image_url(file_path: actor.profile_path, size: :medium, image_type: :profile))
    else
      image_tag('headshot_placeholder.jpg')
    end #if
  end #headshot_for

  def season_number_display(season)
    if season == 0
      "Misc/Extras"
    else
      season
    end
  end
end
