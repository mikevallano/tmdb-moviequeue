# frozen_string_literal: true

module MoviePersonProfilesHelper
  def display_birthday_and_age(profile)
    return 'Not available' if profile.birthday.blank?

    date = profile.birthday.to_date.stamp('January 1st, 2018')
    "#{date} (Age: #{profile.age})"
  end
end
