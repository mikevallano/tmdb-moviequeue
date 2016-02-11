module ListsHelper

  def public_private_indicator(list)
    if list.is_public == true
      "fa fa-group"
    else
      "fa fa-lock"
    end #if
  end #public_private_indicator

end #ListsHelper
