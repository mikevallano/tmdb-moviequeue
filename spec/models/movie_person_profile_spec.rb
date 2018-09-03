# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoviePersonProfile, type: :model do
  let(:movie_person_profile) { build(:movie_person_profile) }

  let(:results_for_known_person) {
    { birthday: '1926-06-28',
      known_for_department: 'Acting',
      deathday: nil,
      id: 14639,
      name: 'Mel Brooks',
      also_known_as: ['Melvin James Kaminsky '],
      gender: 2,
      biography: "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} Melvin Brooks (né Kaminsky, born June 28, 1926) is an American filmmaker, comedian, actor and composer.\n\rHe is known as a creator of broad film farces and comic parodies.\r\nBrooks began his career as a comic and a writer for the early TV variety show Your Show of Shows.\r\n #{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}",
      popularity: 1.644,
      place_of_birth: 'Brooklyn, New York, USA',
      profile_path: '/ndFo3LOYNCUghQTK833N1Wtuynr.jpg',
      adult: false,
      imdb_id: 'nm0000316',
      homepage: nil }
  }

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

  describe 'a valid movie person profile' do
    context 'when has valid params' do
      it 'is valid' do
        expect(movie_person_profile).to be_valid
      end
    end

    context 'when does not have a person_id' do
      it 'is invalid' do
        movie_person_profile.person_id = nil
        expect(movie_person_profile).to_not be_valid
      end
    end

    context 'when does not have a name' do
      it 'is invalid' do
        movie_person_profile.name = nil
        expect(movie_person_profile).to_not be_valid
      end
    end

    context 'when does not have a bio' do
      it 'is invalid' do
        movie_person_profile.bio = nil
        expect(movie_person_profile).to_not be_valid
      end
    end

    context 'when does not have a birthday_and_age' do
      it 'is invalid' do
        movie_person_profile.birthday_and_age = nil
        expect(movie_person_profile).to_not be_valid
      end
    end

    context 'when does not have a profile_path' do
      it 'is invalid' do
        movie_person_profile.profile_path = nil
        expect(movie_person_profile).to_not be_valid
      end
    end
  end

  describe '.parse_result' do
    it 'returns a MoviePersonProfile object' do
      expect(MoviePersonProfile.parse_result(results_for_known_person)).to be_a(MoviePersonProfile)
    end
  end

  describe '.parse_bio' do
    it 'returns a biography if one is present' do
      bio = results_for_known_person[:biography]

      expect(MoviePersonProfile.parse_bio(bio).present?).to be true
    end

    it 'returns a "not available" message if no bio is present' do
      bio = results_for_known_person_without_details[:biography]
      parsed_bio = MoviePersonProfile.parse_bio(bio.clone)
      message = 'not available'

      expect(parsed_bio.downcase.include?(message)).to be true
    end

    it 'replaces carriage returns with <br>' do
      bio = results_for_known_person[:biography]
      parsed_bio = MoviePersonProfile.parse_bio(bio.clone)

      expect(parsed_bio.downcase.include?('<br>')).to be true
      expect(parsed_bio.downcase.include?("\r\n")).to be false
    end
  end

  describe '.standardize_wikipedia_credit' do
    it 'removes starting Wikipedia credit if there is one' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.standardize_wikipedia_credit(bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:starting])).to be false
    end

    it 'removes trailing Wikipedia credit if there is one' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.standardize_wikipedia_credit(bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing])).to be false
    end

    it 'appends "Bio from Wikipedia" if there were any Wikipedia credits' do
      bio = results_for_known_person[:biography]
      stripped_bio = MoviePersonProfile.standardize_wikipedia_credit(bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:standard])).to be true
    end

    it 'appends nothing if there were not any Wikipedia credits' do
      bio = results_for_unknown_person[:biography]
      stripped_bio = MoviePersonProfile.standardize_wikipedia_credit(bio.clone)

      expect(stripped_bio.include?(MoviePersonProfile::WIKIPEDIA_CREDIT[:standard])).to be false
    end
  end

  describe '.wikipedia_credit?' do
    it 'returns true if a starting Wikipedia credit exists' do
      bio = "#{MoviePersonProfile::WIKIPEDIA_CREDIT[:starting]} Bio Goes here."
      expect(MoviePersonProfile.wikipedia_credit?(bio)).to be true
    end

    it 'returns true if a trailing Wikipedia credit exists' do
      bio = "Bio Goes here. #{MoviePersonProfile::WIKIPEDIA_CREDIT[:trailing]}"
      expect(MoviePersonProfile.wikipedia_credit?(bio)).to be true
    end

    it 'returns false if there is no credit for Wikipedia' do
      bio = 'Bio Goes here.'
      expect(MoviePersonProfile.wikipedia_credit?(bio)).to be false
    end
  end

  describe '.parse_birthday' do
    it 'returns "Not available" message if there is no date provided' do
      birthday = nil
      parsed_birthday = MoviePersonProfile.parse_birthday(birthday)
      message = 'not available'

      expect(parsed_birthday.downcase.include?(message)).to be true
    end

    it 'includes the word version of the birthdate in the returned string' do
      birthday = '2000-01-28'
      parsed_birthday = MoviePersonProfile.parse_birthday(birthday)

      expect(parsed_birthday.include?('January')).to be true
    end

    it "includes the person's current age in the returned string" do
      birthday = '2000-01-28'
      current_age = DateAndTimeHelper.years_since_date(birthday.to_date).to_s
      parsed_birthday = MoviePersonProfile.parse_birthday(birthday)

      expect(parsed_birthday.include?(current_age)).to be true
    end
  end
end
