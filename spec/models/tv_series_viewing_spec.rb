require 'rails_helper'

RSpec.describe TVSeriesViewing, type: :model do
  
  context 'with a valid factory' do
    let(:tv_series_viewing) { build(:tv_series_viewing) }
    it 'has a valid factory' do
      expect(tv_series_viewing).to be_valid
    end
  end
  
  context 'without a valid factory' do
    let(:invalid_tv_series_viewing) { build(:invalid_tv_series_viewing) }
    it 'has an invalid factory' do
      expect(invalid_tv_series_viewing).not_to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:show_id) }
    it { is_expected.to validate_presence_of(:started_at) }
  end
end
