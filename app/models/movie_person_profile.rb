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

  def self.parse_result(result)
    id = result[:id]
    profile_path = result[:profile_path]
    name = result[:name]
    bio = result[:biography].present? ? self.parse_bio(result[:biography]) : 'Bio not available.'
    date = Date.parse(result[:birthday]) rescue nil
    birthday_and_age = display_birthday_and_age(date)

    MoviePersonProfile.new(
      person_id: id,
      profile_path: profile_path,
      name: name,
      bio: bio,
      birthday_and_age: birthday_and_age
    )
  end

  def self.parse_bio(bio)
    bio.gsub!(/(From Wikipedia, the free encyclopedia.?)\s+/, '')
    bio.gsub!(/(Description above from).*Wikipedia\s.*\./, "Bio from Wikipedia.")
    bio.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
  end

  def self.display_birthday_and_age(date)
    return "Not available" unless date

    "#{date.stamp('January 1st, 2018')} (Age: #{DateAndTimeHelper.years_since_date(date)})"
  end
end
