# frozen_string_literal: true

class MoviePersonProfile
  attr_accessor :person_id, :name, :bio, :birthday, :deathday, :profile_path

  def initialize(args)
    @person_id = args[:person_id]
    @profile_path = args[:profile_path]
    @name = args[:name]
    @bio = args[:bio]
    @birthday = args[:birthday]
    @deathday = args[:deathday]
  end

  WIKIPEDIA_CREDIT = {
    starting: 'From Wikipedia, the free encyclopedia.',
    trailing: 'Description above from Wikipedia.',
    standard: 'Bio from Wikipedia.'
  }.freeze

  class << self
    def parse_result(result)
      new(
        person_id: result[:id],
        profile_path: result[:profile_path],
        name: result[:name],
        bio: parse_bio(result[:biography]),
        birthday: parse_date(result[:birthday]),
        deathday: parse_date(result[:deathday])
      )
    end

    private

    def parse_bio(biography)
      return 'Bio not available.' if biography.blank?

      standardize_wikipedia_credit(biography)
      biography.gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
    end

    def standardize_wikipedia_credit(bio)
      return '' unless wikipedia_credit?(bio)

      bio = bio.gsub(/(#{WIKIPEDIA_CREDIT[:starting]}?)\s+/, '')
      bio = bio.gsub(/ #{WIKIPEDIA_CREDIT[:trailing]}/, '')
      bio << " #{WIKIPEDIA_CREDIT[:standard]}"
    end

    def wikipedia_credit?(bio)
      bio.include?(WIKIPEDIA_CREDIT[:starting]) || bio.include?(WIKIPEDIA_CREDIT[:trailing])
    end

    def parse_date(date)
      date.nil? ? '' : date
    end
  end

  def age
    return '' if @birthday.blank?

    if @deathday.blank?
      DateAndTimeHelper.years_since_date(@birthday.clone.to_date)
    else
      DateAndTimeHelper.years_between_dates(
        starting_date: @birthday.clone.to_date,
        ending_date: @deathday.clone.to_date
      )
    end
  end
end
