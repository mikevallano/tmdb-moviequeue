module TmdbHelper

  def headshot_for(actor)
    if actor.profile_path.present?
      image_tag("http://image.tmdb.org/t/p/w185#{actor.profile_path}")
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

end #TmdbHelper
