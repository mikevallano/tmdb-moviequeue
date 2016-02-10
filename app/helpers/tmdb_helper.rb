module TmdbHelper

  def headshot_for(actor)
    if actor.profile_path.present? 
      image_tag("http://image.tmdb.org/t/p/w185#{actor.profile_path}")
    else
      image_tag('headshot_placeholder.jpg')
    end #if
  end #headshot_for

end #TmdbHelper
