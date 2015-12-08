require 'rails_helper'

RSpec.describe Tagging, type: :model do
  let(:tagging) { FactoryGirl.create(:tagging) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(tagging).to be_valid
    end

    it { is_expected.to belong_to(:movie) }
    it { is_expected.to belong_to(:tag) }
    it { is_expected.to belong_to(:user) }

  end #valid factory context

end