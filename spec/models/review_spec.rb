require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:review) { FactoryGirl.build(:review) }
  let(:invalid_review) { FactoryGirl.build(:invalid_review) }

  it { is_expected.to validate_presence_of(:body) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(review).to be_valid
    end

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie) }

  end #valid factory context

  it "is invalid without a name" do
    expect(invalid_review).not_to be_valid
  end
end