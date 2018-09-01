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

end
