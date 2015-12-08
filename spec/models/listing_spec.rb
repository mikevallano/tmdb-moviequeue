require 'rails_helper'

RSpec.describe Listing, type: :model do
  let(:listing) { FactoryGirl.create(:listing) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(listing).to be_valid
    end

    it { is_expected.to belong_to(:movie) }
    it { is_expected.to belong_to(:list) }

  end #valid factory context

end