require 'rails_helper'

RSpec.describe Listing, type: :model do
  let(:listing) { FactoryGirl.create(:listing) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(listing).to be_valid
    end

  end #valid factory context

end