module ApplicationHelper
 def page_title
   if content_for?(:title)
     "ReactBetter - #{content_for(:title)}"
    else
     "ReactBetter - Choose a Mindful, Happier Life"
   end #content_for
 end #page_title
end #ApplicationHelper