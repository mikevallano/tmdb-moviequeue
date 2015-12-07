require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:movie) { FactoryGirl.create(:movie) }
  let(:invalid_movie) { FactoryGirl.build(:invalid_movie) }

  it { is_expected.to validate_presence_of(:tmdb_id) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(movie).to be_valid
    end

  end #valid factory context

  it "is invalid without a tmdb_id" do
    expect(invalid_movie).not_to be_valid
  end
end