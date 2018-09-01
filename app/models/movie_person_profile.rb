  def initialize(person_id:, name:, bio:, birthday_and_age:, profile_path:)
    @birthday_and_age = birthday_and_age
  attr_accessor :person_id, :name, :bio, :birthday_and_age, :profile_path
    date = Date.parse(result[:birthday]) rescue nil
    birthday_and_age = display_birthday_and_age(date)
      birthday_and_age: birthday_and_age
  def self.display_birthday_and_age(date)
    return "Not available" unless date

    "#{date.stamp('January 1st, 2018')} (Age: #{DateAndTimeHelper.years_since_date(date)})"
  end
