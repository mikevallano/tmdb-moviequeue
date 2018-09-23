require 'rails_helper'

RSpec.describe DateAndTimeHelper, type: :helper do
  describe '.display_time' do
    it 'displays hours and minutes' do
      time_in_minutes = 190
      expect(DateAndTimeHelper.display_time(time_in_minutes)).to eq('3h 10m')
    end

    it 'displays only hours when the minute-count is divisible by 60' do
      time_in_minutes = 120
      expect(DateAndTimeHelper.display_time(time_in_minutes)).to eq('2hr')
    end

    it 'displays nothing if there is no runtime' do
      time_in_minutes = nil
      expect(DateAndTimeHelper.display_time(time_in_minutes)).to eq(nil)
    end
  end

  describe '.years_since_date' do
    it 'returns the difference in years between a given date and today' do
      year_ago = Time.zone.today - 366
      expect(DateAndTimeHelper.years_since_date(year_ago)).to eq(1)
    end
  end

  describe '.years_between_dates' do
    it 'returns the difference in years between two given dates' do
      year_ago = Time.zone.today - 366
      this_year = Time.zone.today
      expect(DateAndTimeHelper.years_between_dates(
        starting_date: year_ago,
        ending_date: this_year
        )).to eq(1)
    end

    it 'takes into account whether the day has happened yet in the ending date' do
      starting_date = '2000-06-01'.to_date
      premature_ending_date = '2001-04-01'.to_date
      mature_ending_date = '2001-12-01'.to_date

      expect(DateAndTimeHelper.years_between_dates(
        starting_date: starting_date,
        ending_date: premature_ending_date
        )).to eq(0)

      expect(DateAndTimeHelper.years_between_dates(
        starting_date: starting_date,
        ending_date: mature_ending_date
        )).to eq(1)
    end
  end
end
