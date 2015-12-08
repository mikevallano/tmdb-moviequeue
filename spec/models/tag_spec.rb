require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { FactoryGirl.build(:tag) }
  let(:invalid_tag) { FactoryGirl.build(:invalid_tag) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(tag).to be_valid
    end

  end #valid factory context

  it "is invalid without a name" do
    expect(invalid_tag).not_to be_valid
  end
end