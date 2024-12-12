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

    describe "preventing a user from creating duplicate active viewings for the same series" do
      let(:user) { create(:user) }
      let(:show_id) { '123' }
      let(:original_tv_series_viewing) { create(:tv_series_viewing, user: user, show_id: show_id, ended_at: original_viewing_ending_timestamp) }
      
      context "when the user has an existing inactive viewing for the series" do
        let(:original_viewing_ending_timestamp) { '2024-05-01'.to_datetime }
        let(:new_tv_series_viewing) { build(:tv_series_viewing, user: original_tv_series_viewing.user, show_id: original_tv_series_viewing.show_id ) }

        it "creating a new viewing for the same series is valid" do
          expect(original_tv_series_viewing.active?).to be(false)
          expect(new_tv_series_viewing).to be_valid
        end
      end

      context "when the user has an existing active viewing for the series" do
        let(:original_viewing_ending_timestamp) { nil }
        let(:new_tv_series_viewing) { build(:tv_series_viewing, user: original_tv_series_viewing.user, show_id: original_tv_series_viewing.show_id ) }

        it "creating a new viewing for the same series is not valid" do
          expect(original_tv_series_viewing.active?).to be(true)
          expect(new_tv_series_viewing).to_not be_valid
        end
      end
      
      context "when the user has an existing active viewing for the series and another user want to start that series" do
        let(:original_viewing_ending_timestamp) { nil }
        let(:another_user) { create(:user) }
        let(:new_tv_series_viewing) { build(:tv_series_viewing, user: another_user, show_id: original_tv_series_viewing.show_id ) }

        it "creating a new viewing for the same series is valid" do
          expect(original_tv_series_viewing.active?).to be(true)
          expect(new_tv_series_viewing).to be_valid
        end
      end
    end
  end

  describe "scopes" do
    describe "active" do
      let(:active_tv_series_viewing) { create(:tv_series_viewing, ended_at: nil) }
      let(:inactive_tv_series_viewing) { create(:tv_series_viewing, ended_at: '2024-05-01'.to_date) }
      it "includes active viewings" do
        expect(described_class.active).to include(active_tv_series_viewing)
      end

      it "excludes inactive viewings" do
        expect(described_class.active).to_not include(inactive_tv_series_viewing)
      end
    end
  end

  describe "active?" do
    context "when a viewing is currently active" do
      let(:tv_series_viewing) { build(:tv_series_viewing, ended_at: nil) }
      it "returns true" do
        expect(tv_series_viewing.active?).to eq(true)
      end
    end

    context "when a viewing is currently inactive" do
      let(:tv_series_viewing) { build(:tv_series_viewing, ended_at: '2024-05-01'.to_date) }
      it "returns false" do
        expect(tv_series_viewing.active?).to eq(false)
      end
    end
  end
end
