# frozen_string_literal: true

require 'rails_helper'

describe MoviePersonProfilesHelper, type: :helper do
  let(:profile) { build(:movie_person_profile) }

  describe '#display_birthday_and_age' do
    it 'includes the word version of the birthdate in the returned string' do
      profile.birthday = '2000-01-28'

      expect(display_birthday_and_age(profile).include?('January')).to be true
    end

    it "includes the person's current age in the returned string" do
      profile.birthday = '2000-01-28'
      current_age = DateAndTimeHelper.years_since_date(profile.birthday.to_date).to_s

      expect(display_birthday_and_age(profile).include?(current_age)).to be true
    end

    it "returns 'Not available' if there is no birthday data" do
      profile.birthday = ''

      expect(display_birthday_and_age(profile)).to eq('Not available')
    end
  end
end
