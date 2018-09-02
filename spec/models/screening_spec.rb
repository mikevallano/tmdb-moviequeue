require 'rails_helper'

RSpec.describe Screening, type: :model do
  let(:screening) { FactoryBot.build(:screening) }
  let(:invalid_screening) { FactoryBot.build(:invalid_screening) }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:movie) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(screening).to be_valid
    end

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie) }

  end #valid factory context

  it "is invalid without a user" do
    expect(invalid_screening).not_to be_valid
  end
end