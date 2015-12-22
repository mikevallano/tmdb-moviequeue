require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:rating) { FactoryGirl.build(:rating) }
  let(:too_low_rating) { FactoryGirl.build(:rating, value: 0) }
  let(:too_high_rating) { FactoryGirl.build(:rating, value: 11) }
  let(:invalid_rating) { FactoryGirl.build(:invalid_rating) }

  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:movie) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(rating).to be_valid
    end

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie) }

  end #valid factory context

  context "with an invalid factory" do

    it "is invalid without a value" do
      expect(invalid_rating).not_to be_valid
    end

    it "is invalid when a rating is too low" do
      expect(too_low_rating).not_to be_valid
    end

    it "is invalid when a rating is too high" do
      expect(too_high_rating).not_to be_valid
    end

  end #invalid factory context
end