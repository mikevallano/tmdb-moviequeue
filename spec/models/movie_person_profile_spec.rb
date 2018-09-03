# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MoviePersonProfile, type: :model do
  let(:movie_person_profile) { build(:movie_person_profile) }

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
  end
    # let(:reading_card) { ReadingCard.new(reading_card_params) }
    # let(:card) { build(:card) }
    # let(:name) { 'name' }
    # let(:theme) { 'theme' }
    # let(:keywords) { 'keywords' }
    # let(:orientation) { 'orientation' }
    #
    # let(:reading_card_params) {
    #   {
    #     card: card,
    #     name: name,
    #     theme: theme,
    #     keywords: keywords,
    #     orientation: orientation
    #   }
    # }

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
