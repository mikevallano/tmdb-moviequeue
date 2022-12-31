# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoviePersonProfile, type: :model do
  let(:movie_person_profile) { build(:movie_person_profile) }
  let(:living_movie_person_profile) { build(:living_movie_person_profile) }
  let(:deceased_movie_person_profile) { build(:deceased_movie_person_profile) }

  let(:results_for_known_person) {
    { birthday: '1963-12-18',
      known_for_department: 'Acting',
      deathday: nil,
      id: 287,
      name: 'Brad Pitt',
      also_known_as:
        ['برد پیت',
         'William Bradley Pitt ',
         'Бред Питт',
         'Бред Пітт',
         'Buratto Pitto',
         'Брэд Питт',
         '畢·彼特',
         'ブラッド・ピット',
         '브래드 피트',
         'براد بيت',
         'แบรด พิตต์'],
      gender: 2,
      biography: "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} William Bradley \"Brad\" Pitt (born December 18, 1963) is an American actor and film producer. Pitt has received tw and four Golden Globe Award nominations, winning one.\n\rHe has been described as one of the world's most attractive menreceived substantial media attention.\r\n #{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}",
      popularity: 15.192,
      place_of_birth: 'Shawnee, Oklahoma, USA',
      profile_path: '/kU3B75TyRiCgE270EyZnHjfivoq.jpg',
      adult: false,
      imdb_id: 'nm0000093',
      homepage: nil }
    }

  # let(:results_for_known_person_who_died) {
  #   { birthday: '1922-06-10',
  #     known_for_department: 'Acting',
  #     deathday: '1969-06-22',
  #     id: 9066,
  #     name: 'Judy Garland',
  #     also_known_as: ['Joots Garland', 'Frances Ethel Gumm', 'Baby Gumm', '주디 갈랜드'],
  #     gender: 1,
  #     biography: "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} Judy Garland (June 10, 1922 – June 22, 1969) was an American actress and singer.\n\rRespected for her versatility, she received a juvenile Academy Award, won a Golden Globe Award, as well as Grammy Awards and a Special Tony Award.\r\n #{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}",
  #     popularity: 2.62,
  #     place_of_birth: 'Grand Rapids, Minnesota, USA',
  #     profile_path: '/dkhMrLSfnqS3fmxWuXaEMwxN0Tf.jpg',
  #     adult: false,
  #     imdb_id: 'nm0000023',
  #     homepage: nil }
  # }

  let(:results_for_known_person_without_details) {
    { birthday: nil,
      known_for_department: 'Acting',
      deathday: nil,
      id: 1578761,
      name: 'Christopher Maurer',
      also_known_as: [],
      gender: 0,
      biography: '',
      popularity: 0,
      place_of_birth: nil,
      profile_path: nil,
      adult: false,
      imdb_id: '',
      homepage: nil }
  }

  let(:results_for_unknown_person) {
    { birthday: nil,
      known_for_department: nil,
      deathday: nil,
      id: 1172982,
      name: 'unknown',
      also_known_as: [],
      gender: 0,
      biography: '',
      popularity: 0.12,
      place_of_birth: nil,
      profile_path: nil,
      adult: false,
      imdb_id: '',
      homepage: nil }
  }

  describe '.parse_result' do
    it 'returns a MoviePersonProfile object' do
      expect(MoviePersonProfile.parse_result(results_for_known_person)).to be_a(MoviePersonProfile)
    end
  end

  describe 'private.parse_bio' do
    it 'returns a biography if one is present' do
      bio = results_for_known_person[:biography]

      expect(MoviePersonProfile.send(:parse_bio, bio).present?).to be true
    end

    it 'returns a "not available" message if no bio is present' do
      bio = results_for_known_person_without_details[:biography]
      parsed_bio = MoviePersonProfile.send(:parse_bio, bio.clone)
      message = 'not available'

      expect(parsed_bio.downcase.include?(message)).to be true
    end

    it 'replaces carriage returns with <br>' do
      bio = results_for_known_person[:biography]
      parsed_bio = MoviePersonProfile.send(:parse_bio, bio.clone)

      expect(parsed_bio.downcase.include?('<br>')).to be true
      expect(parsed_bio.downcase.include?("\r\n")).to be false
    end
  end

  describe 'private.standardize_wikipedia_credit' do
    it 'removes starting Wikipedia credit if there is one' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.send(:standardize_wikipedia_credit, bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:starting])).to be false
    end

    it 'removes trailing Wikipedia credit if there is one' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.send(:standardize_wikipedia_credit, bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing])).to be false
    end

    it 'appends "Bio from Wikipedia" if there were any Wikipedia credits' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.send(:standardize_wikipedia_credit, bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:standard])).to be true
    end

    it 'appends nothing if there were not any Wikipedia credits' do
      bio = results_for_unknown_person[:biography]
      stripped_bio = MoviePersonProfile.send(:standardize_wikipedia_credit, bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:standard])).to be false
    end
  end

  describe 'private.wikipedia_credit?' do
    it 'returns true if a starting Wikipedia credit exists' do
      bio = "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} Bio Goes here."

      expect(MoviePersonProfile.send(:wikipedia_credit?, bio)).to be true
    end

    it 'returns true if a trailing Wikipedia credit exists' do
      bio = "Bio Goes here. #{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}"
      expect(MoviePersonProfile.send(:wikipedia_credit?, bio)).to be true
    end

    it 'returns false if there is no credit for Wikipedia' do
      bio = 'Bio Goes here.'
      expect(MoviePersonProfile.send(:wikipedia_credit?, bio)).to be false
    end
  end

  describe 'private.parse_date' do
    it 'returns an empty string if there is no date provided' do
      birthday = nil
      parsed_birthday = MoviePersonProfile.send(:parse_date, birthday)

      expect(parsed_birthday).to eq('')
    end

    it 'returns the date in string format if there is a date provided' do
      birthday = '2018-01-31'
      parsed_birthday = MoviePersonProfile.send(:parse_date, birthday)

      expect(parsed_birthday).to eq(birthday)
    end
  end

  describe '#age' do
    it 'returns an empty string if there is no birthday' do
      movie_person_profile.birthday = ''
      expect(movie_person_profile.age).to eq('')
    end

    it "returns a living person's current age if a birthday is provided" do
      calculated_age = DateAndTimeHelper.years_since_date(living_movie_person_profile.birthday.to_date)
      expect(living_movie_person_profile.age).to eq(calculated_age)
    end

    it "returns a deceased person's age at death age if a birth & death dates are provided" do
      calculated_age = DateAndTimeHelper.years_between_dates(
        starting_date: deceased_movie_person_profile.birthday.to_date,
        ending_date: deceased_movie_person_profile.deathday.to_date
      )
      expect(deceased_movie_person_profile.age).to eq(calculated_age)
    end
  end
end
