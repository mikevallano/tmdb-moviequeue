require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:invalid_user) { FactoryBot.build(:invalid_user) }
  let(:list) { FactoryBot.create(:list, owner_id: user.id) }
  let(:list2) { FactoryBot.create(:list, owner_id: user.id) }
  let(:movie) { FactoryBot.create(:movie) }
  let(:movie2) { FactoryBot.create(:movie) }
  let(:listing) { FactoryBot.create(:listing, list_id: list.id, user_id: user.id, movie_id: movie.id ) }
  let(:listing2) { FactoryBot.create(:listing, list_id: list2.id, user_id: user.id, movie_id: movie2.id ) }

  it { is_expected.to validate_uniqueness_of(:username) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to have_many(:lists) }
  it { is_expected.to have_many(:listings) }
  it { is_expected.to have_many(:memberships) }
  it { is_expected.to have_many(:member_lists) }
  it { is_expected.to have_many(:member_listings) }
  it { is_expected.to have_many(:movies) }
  it { is_expected.to have_many(:member_movies) }
  it { is_expected.to have_many(:tags) }
  it { is_expected.to have_many(:taggings) }
  it { is_expected.to have_many(:sent_invites) }
  it { is_expected.to have_many(:reviews) }
  it { is_expected.to have_many(:reviewed_movies) }
  it { is_expected.to have_many(:ratings) }
  it { is_expected.to have_many(:rated_movies) }
  it { is_expected.to have_many(:screenings) }
  it { is_expected.to have_many(:watched_movies) }

  context "with a valid factory" do
    before(:each) do
      user
      movie
      list
      listing
    end

    it "has a valid factory" do
      expect(user).to be_valid
    end

    it "responds to all_lists" do
      expect(user.all_lists).to include(list)
    end

    it "responds to all_listings" do
      expect(user.all_listings).to include(listing)
    end

    it "responds to lists_except_movie" do
      movie2
      list2
      listing2
      expect(user.lists_except_movie(movie)).not_to include(list)
      expect(user.lists_except_movie(movie)).to include(list2)
    end

    it "returns all lists if movie is not yet on a list" do
      list2
      expect(user.lists_except_movie).to match_array([list, list2])
    end

    it "responds to all_movies" do
      expect(user).to respond_to(:all_movies)
    end

    it "responds to all_movies_by_title" do
      expect(user).to respond_to(:all_movies_by_title)
    end

    it "responds to all_movies_by_shortest_runtime" do
      expect(user).to respond_to(:all_movies_by_shortest_runtime)
    end

    it "responds to all_movies_by_recent_release_date" do
      expect(user).to respond_to(:all_movies_by_recent_release_date)
    end

    it "responds to all_movies_by_shortest_runtime" do
      expect(user).to respond_to(:all_movies_by_shortest_runtime)
    end

    it "responds to all_movies_by_highest_vote_average" do
      expect(user).to respond_to(:all_movies_by_highest_vote_average)
    end

    it "responds to all_movies_by_recently_watched" do
      expect(user).to respond_to(:all_movies_by_recently_watched)
    end

    it "responds to all_movies_by_all_movies_not_on_a_list" do
      expect(user).to respond_to(:all_movies_not_on_a_list)
    end

    it "responds to all_movies_by_all_movies_by_unwatched" do
      expect(user).to respond_to(:all_movies_by_unwatched)
    end

    it "responds to all_movies_by_all_movies_by_unwatched" do
      expect(user).to respond_to(:all_movies_by_watched)
    end

  end #valid factory context

  context "without a valid factory" do
    it "has an invalid factory" do
      expect(invalid_user).not_to be_valid
    end
  end

end #final
