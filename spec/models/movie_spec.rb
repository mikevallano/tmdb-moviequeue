require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:user) { create(:user) }
  let(:movie) { create(:movie) }
  let(:movie2) { create(:movie) }
  let(:list) { create(:list, owner_id: user.id) }
  let(:listing) { create(:listing,
                  movie_id: movie2.id,
                  list_id: list.id,
                  user_id: user.id) }
  let(:invalid_movie) { build(:invalid_movie) }
  let(:fargo) { create(:movie,
                title: "Fargo",
                runtime: 90,
                vote_average: 8,
                release_date: Date.today - 8000,
                tmdb_id: 275) }
  let(:no_country) { create(:movie,
                     title: "No Country for Old Men",
                     runtime: 100,
                     vote_average: 9,
                     release_date: Date.today - 6000) }
  let(:fargo_listing) { create(:listing,
                        list_id: list.id,
                        movie_id: fargo.id,
                        priority: 9) }
  let(:no_country_listing) { create(:listing,
                             list_id: list.id,
                             movie_id: no_country.id,
                             priority: 8) }

  it { is_expected.to validate_presence_of(:tmdb_id) }

  context "with a valid factory" do
    it "has a valid factory" do
      expect(movie).to be_valid
    end

    it { is_expected.to have_many(:listings) }
    it { is_expected.to have_many(:lists) }

  end #valid factory context

  it "is invalid without a tmdb_id" do
    expect(invalid_movie).not_to be_valid
  end


  describe 'Sorting' do

    before do
      fargo_listing; no_country_listing
    end

    it 'sorts by highest priority' do
      expect(Movie.by_highest_priority(list).first).to eq(fargo)
    end

    it 'sorts by recently added' do
      no_country_listing.update(created_at: 2.days.ago.to_date)
      expect(Movie.by_recently_added(list).first).to eq(fargo)
    end

  end


end
