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

  WIKIPEDIA_CREDIT = {
    starting: 'From Wikipedia, the free encyclopedia.',
    trailing: 'Description above from Wikipedia.',
    standard: 'Bio from Wikipedia.'
  }.freeze

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

    def parse_bio(biography)
      return 'Bio not available.' if biography.blank?

      standardize_wikipedia_credit(biography)
      biography.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
    end

    def standardize_wikipedia_credit(bio)
      return '' unless wikipedia_credit?(bio)

      bio.gsub!(/(#{WIKIPEDIA_CREDIT[:starting]}?)\s+/, '')
      bio.gsub!(/ #{WIKIPEDIA_CREDIT[:trailing]}/, '')
      bio << " #{WIKIPEDIA_CREDIT[:standard]}"
    end

    def wikipedia_credit?(bio)
      bio.include?(WIKIPEDIA_CREDIT[:starting]) || bio.include?(WIKIPEDIA_CREDIT[:trailing])
    end

    def parse_birthday(birthday)
      return 'Not available' unless birthday

      date = Date.parse(birthday)
      "#{date.stamp('January 1st, 2018')} (Age: #{DateAndTimeHelper.years_since_date(date)})"
    end
  end
end
