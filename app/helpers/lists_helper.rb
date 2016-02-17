module ListsHelper

  def public_private_indicator(list)
    if list.is_public == true
      "fa fa-group"
    else
      "fa fa-lock"
    end #if
  end #public_private_indicator

  def current_priority(list, movie)
    Listing.find_by(list_id: list.id, movie_id: movie.id).priority
  end

end #ListsHelper
