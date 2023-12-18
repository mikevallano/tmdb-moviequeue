module ListsHelper

  def public_private_indicator(list)
    if list.is_public == true
      "fa fa-group"
    else
      "fa fa-lock"
    end #if
  end #public_private_indicator

  def public_private_display(list)
    list.is_public ? 'Public' : 'Private'
  end

  def current_priority(list, movie)
    # see issue #394. the safe navigation fixes it, but worth
    # more of a look
    Listing.find_by(list_id: list.id, movie_id: movie.id)&.priority
  end

end #ListsHelper
