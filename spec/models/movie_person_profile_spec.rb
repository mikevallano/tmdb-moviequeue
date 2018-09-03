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
    xit 'removes lines about Wikipedia' do
    end

    xit 'appends "Bio from Wikipedia"' do
    end

    xit 'replaces carriage returns with <br>' do
    end
  end

  describe '.display_birthday_and_age' do
    xit 'returns "Not available" if there is no Date' do
    end

    xit 'returns a string with the birthdate and Age' do
    end
  end
end
