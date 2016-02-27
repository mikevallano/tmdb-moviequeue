module ApplicationHelper
 def page_title
   if content_for?(:title)
     "Flicks On Lists - #{content_for(:title)}"
    else
     "Flicks On Lists - Personal Movie Playlist"
   end #content_for
 end #page_title
end #ApplicationHelper