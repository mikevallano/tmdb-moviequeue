# frozen_string_literal: true

module MoviePersonProfilesHelper
  def display_birthday_info(profile)
    return 'Not available' if profile.birthday.blank?

    date = profile.birthday.to_date.stamp('January 1st, 2018')
    profile.deathday.blank? ? "#{date} (Age: #{profile.age})" : "#{date}, Deceased (Age: #{profile.age})"
  end

  def actor_movie_posters_uri(actor)
    "#{root_url}tmdb/actor_search?actor=#{actor.name.gsub(' ', '+')}"
  end
end
