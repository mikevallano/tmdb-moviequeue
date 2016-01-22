require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:user) { FactoryGirl.create(:user) }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:movie2) { FactoryGirl.create(:movie) }
  let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
  let(:listing) { FactoryGirl.create(:listing, movie_id: movie2.id, list_id: list.id, user_id: user.id) }
  let(:invalid_movie) { FactoryGirl.build(:invalid_movie) }

  it { is_expected.to validate_presence_of(:tmdb_id) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(movie).to be_valid
    end

    it { is_expected.to have_many(:listings) }
    it { is_expected.to have_many(:lists) }

    it "filters by user" do
      user
      list
      listing
      movie
      movie2
      expect(user.all_movies.count).to eq(1)
      expect(Movie.count).to eq(2)
    end

  end #valid factory context

  it "is invalid without a tmdb_id" do
    expect(invalid_movie).not_to be_valid
  end
end