require 'rails_helper'

RSpec.describe Membership, type: :model do
  let(:membership) { FactoryGirl.create(:membership) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(membership).to be_valid
    end

    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:list) }

  end #valid factory context

end