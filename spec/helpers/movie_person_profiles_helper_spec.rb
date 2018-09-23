# frozen_string_literal: true

require 'rails_helper'

describe MoviePersonProfilesHelper, type: :helper do
  let(:profile) { build(:movie_person_profile) }
  let(:living_profile) { build(:living_movie_person_profile) }
  let(:deceased_profile) { build(:deceased_movie_person_profile) }


  describe '#display_birthday_info' do
    it 'includes the word version of the birthdate in the returned string' do
      profile.birthday = '2000-01-28'

      expect(display_birthday_info(profile).include?('January')).to be true
    end

    it "includes a living person's current age in the returned string" do
      current_age = DateAndTimeHelper.years_since_date(living_profile.birthday.to_date).to_s

      expect(display_birthday_info(living_profile).include?(current_age)).to be true
    end

    it "includes a deceased person's age at death in the returned string" do
      current_age = DateAndTimeHelper.years_between_dates(
        starting_date: deceased_profile.birthday.to_date,
        ending_date: deceased_profile.deathday.to_date
      ).to_s

      expect(display_birthday_info(deceased_profile).include?(current_age)).to be true
    end

    it "indicates that a deceased person has deceased" do
      keyword = 'deceased'

      expect(display_birthday_info(deceased_profile).downcase.include?(keyword)).to be true
      expect(display_birthday_info(living_profile).downcase.include?(keyword)).to be false
    end

    it "returns 'Not available' if there is no birthday data" do
      profile.birthday = ''

      expect(display_birthday_info(profile)).to eq('Not available')
    end
  end
end
