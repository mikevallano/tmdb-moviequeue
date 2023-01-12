require 'rails_helper'

RSpec.describe Movie, type: :model do
  let(:user) { create(:user, username: 'useruno') }
  let(:user2) {create(:user, username: 'userdos')}
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
                release_date: 15.years.ago.to_date,
                tmdb_id: 275) }
  let(:no_country) { create(:movie,
                     title: "No Country for Old Men",
                     runtime: 117,
                     vote_average: 9,
                     release_date: 10.years.ago.to_date) }
  let(:lebowski) { create(:movie,
                     title: "Big Lebowski",
                     runtime: 100,
                     vote_average: 9,
                     release_date: 12.years.ago.to_date) }
  let(:fargo_listing) { create(:listing,
                        list_id: list.id,
                        movie_id: fargo.id,
                        priority: 5,
                        created_at: 1.day.ago) }
  let(:lebowski_listing) { create(:listing,
                        list_id: list.id,
                        movie_id: lebowski.id,
                        priority: 2,
                        created_at: 3.days.ago) }
  let(:no_country_listing) { create(:listing,
                             list_id: list.id,
                             movie_id: no_country.id,
                             priority: 4,
                             created_at: 3.days.ago) }
  let(:fargo_screening) {create(:screening,
                          user: user,
                          movie: fargo,
                          date_watched: 30.days.ago)}
  let(:fargo_screening2) {create(:screening,
                          user: user,
                          movie: fargo,
                          date_watched: 10.days.ago)}
  let(:no_country_screening) {create(:screening,
                          user: user,
                          movie: no_country)}
  let(:user2_fargo_screening) {create(:screening,
                          user: user2,
                          movie: fargo,
                          date_watched: 20.days.ago)}
  let(:lewbowski_screening) {create(:screening,
                          user: user,
                          movie: lebowski)}
  let(:membership1) {create(:membership,
                            member: user,
                            list: list)}
  let(:membership2) {create(:membership,
                            member: user2,
                            list: list)}
  let(:tag) {create(:tag, name: 'killer')}
  let(:tagging) {create(:tagging,
                         tag: tag,
                         movie: fargo,
                         user: user)}

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
      expect(Movie.by_recently_added(list).first).to eq(fargo)
    end

    context 'with screenings' do

      before do
        user.screenings << fargo_screening
        membership1; membership2
      end

      it '#by_watched_by_user' do
        create(:screening, user: user2, movie: no_country, date_watched: 1.day.ago)
        create(:screening, user: user2, movie: no_country, date_watched: 1.week.ago)
        create(:screening, user: user2, movie: no_country, date_watched: 1.month.ago)
        expect(user.watched_movies.distinct).to eq([fargo])
        expect(user2.watched_movies.distinct).to eq([no_country])
        expect(Movie.by_watched_by_user(list, user).map(&:title)).to eq([fargo.title, no_country.title])
        expect(Movie.by_watched_by_user(list, user2).map(&:title)).to eq([no_country.title, fargo.title])
      end

      it '#by_unwatched_by_user' do
        create(:screening, user: user2, movie: no_country, date_watched: 1.day.ago)
        create(:screening, user: user2, movie: no_country, date_watched: 1.week.ago)
        create(:screening, user: user2, movie: no_country, date_watched: 1.month.ago)
        expect(user.watched_movies.distinct).to eq([fargo])
        expect(user2.watched_movies.distinct).to eq([no_country])
        expect(Movie.by_unwatched_by_user(list, user).map(&:title)).to eq([no_country.title, fargo.title])
        expect(Movie.by_unwatched_by_user(list, user2).map(&:title)).to eq([fargo.title, no_country.title])
      end

      it '#by_recently_watched_by_user' do
        create(:screening, user: user, movie: no_country, date_watched: 1.day.ago)
        create(:screening, user: user, movie: no_country, date_watched: 1.week.ago)
        create(:screening, user: user, movie: no_country, date_watched: 1.month.ago)
        create(:listing, list: list, movie: lebowski)
        fargo_screening.update(date_watched: 1.hour.ago)
        expect(user.watched_movies.distinct).to match_array([fargo, no_country])
        expect(user.all_movies).to match_array([fargo, no_country, lebowski])
        expect(Movie.by_recently_watched_by_user(user).map(&:title)).to eq([fargo.title, no_country.title, lebowski.title])
      end

      it 'returns count of times a user has seen a movie' do
        user.screenings << fargo_screening2
        expect(fargo.times_seen_by(user)).to eq(2)
      end

      it 'returns uniq movies watched by user' do
        user.screenings << no_country_screening
        user.screenings << lewbowski_screening
        user.screenings << fargo_screening2
        expect(Movie.watched_by_user(user)).to match_array([fargo, no_country, lebowski])
      end

      it 'returns movies not seen by a user' do
        user.screenings << no_country_screening
        lebowski_listing
        expect(Movie.unwatched_by_user(user)).to match_array([lebowski])
      end

      it 'returns date of most recent screening by user' do
        user.screenings << fargo_screening2
        expect(fargo.most_recent_screening_by(user)).to eq(fargo_screening2.date_watched.stamp('1/2/2001'))
      end

      it 'returns the date the movie was added to a list' do
        expect(fargo.date_added_to_list(list).to_date).to eq(fargo_listing.created_at.to_date)
      end

    end

    context 'tags' do
      before do
        tagging
      end

      it 'returns movies with a tag' do
        expect(Movie.tagged_with(tag.name, user)).to match_array([fargo])
      end

      it 'returns tag list for a movie' do
        expect(fargo.tag_list(user)).to match_array([tag])
      end
    end

    context 'genre' do
      before do
        fargo.update(genres: ['Comedy'])
      end

      it 'returns movies by genre' do
        expect(Movie.by_genre('Comedy')).to match_array([fargo])
      end
    end

    context 'priority' do

      it 'returns priority for a movie by list' do
        expect(fargo.priority(list)).to eq(5)
      end

      it 'returns prirotity text for a movie by list' do
        expect(fargo.priority_text(list)).to eq('Top')
      end

    end

  end


end
