class MoviePersonProfile
  include ActiveModel::Validations

  def initialize(person_id:, name:, bio:, birthday_and_age:, profile_path:)
    @person_id = person_id
    @profile_path = profile_path
    @name = name
    @bio = bio
    @birthday_and_age = birthday_and_age
  end

  attr_accessor :person_id, :name, :bio, :birthday_and_age, :profile_path

  validates :person_id, :name, :bio, :birthday_and_age, :profile_path, presence: true


  class << self
    def parse_result(result)
      MoviePersonProfile.new(
        person_id: result[:id],
        profile_path: result[:profile_path],
        name: result[:name],
        bio: parse_bio(result[:biography]),
        birthday_and_age: parse_birthday(result[:birthday])
      )
    end

  def self.display_birthday_and_age(date)
    return "Not available" unless date
    def parse_bio(biography)
      return 'Bio not available.' if biography.blank?

    "#{date.stamp('January 1st, 2018')} (Age: #{DateAndTimeHelper.years_since_date(date)})"
      standardize_wikipedia_credit(biography)
      biography.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
    end
  end
end
