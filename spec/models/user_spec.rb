require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.build(:user) }
  let(:invalid_user) { FactoryGirl.build(:invalid_user) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(user).to be_valid
    end

    it { is_expected.to have_many(:lists) }
    it { is_expected.to have_many(:listings) }
    it { is_expected.to have_many(:movies) }


  end #valid factory context

  context "without a valid factory" do
    it "has an invalid factory" do
      expect(invalid_user).not_to be_valid
    end
  end

end #final