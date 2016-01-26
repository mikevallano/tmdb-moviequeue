module ApplicationHelper
 def page_title
   if content_for?(:title)
     "MovieQueue - #{content_for(:title)}"
    else
     "MovieQueue - Personal Movie Playlist"
   end #content_for
 end #page_title
end #ApplicationHelper