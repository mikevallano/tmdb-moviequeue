require 'rails_helper'

RSpec.describe Listing, type: :model do
  let(:listing) { FactoryGirl.build(:listing) }
  let(:invalid_listing) { FactoryGirl.build(:invalid_listing) }

  it { is_expected.to validate_presence_of(:list) }
  it { is_expected.to validate_presence_of(:movie) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(listing).to be_valid
    end

    it { is_expected.to belong_to(:movie) }
    it { is_expected.to belong_to(:list) }

  end #valid factory context

  context "with an invalid factory" do
    it "is invalid without a movie" do
      expect(invalid_listing).not_to be_valid
    end
  end

end