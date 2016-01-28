require 'rails_helper'

RSpec.describe List, type: :model do
  let(:list) { FactoryGirl.build(:list) }
  let(:invalid_list) { FactoryGirl.build(:invalid_list) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:owner_id) }

  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:listings) }
  it { is_expected.to have_many(:movies) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(list).to be_valid
    end

    it "is responds to description" do
      expect(list).to respond_to(:description)
    end

    it "has a default false is_main field" do
      expect(list.is_main).to be false
    end

    it "has a default false is_public field" do
      expect(list.is_public).to be false
    end

    it "belongs has an owner_id" do
      expect(list.owner_id).not_to be nil
    end

  end #valid factory context

  it "is invalid without a name" do
    expect(invalid_list).not_to be_valid
  end
end
