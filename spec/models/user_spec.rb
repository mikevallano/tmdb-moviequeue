require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:list_owned_by_user2) { create(:list, owner: user2) }
  let(:invalid_user) { build(:invalid_user) }
  let(:list) { create(:list, owner_id: user.id) }
  let(:list2) { create(:list, owner_id: user.id) }
  let(:movie) { create(:movie, title: 'movie') }
  let(:movie2) { create(:movie, title: 'movie2') }
  let!(:listing) { create(:listing, list_id: list.id, user_id: user.id, movie_id: movie.id ) }
  let(:listing2) { create(:listing, list_id: list2.id, user_id: user.id, movie_id: movie2.id ) }

  context 'with a valid factory' do
    it 'has a valid factory' do
      expect(user).to be_valid
    end

    it 'returns correct lists for #all_lists' do
      membership = create(:membership, member: user, list: list_owned_by_user2)
      expect(user.all_lists).to include(list)
      expect(user.all_lists).to include(list_owned_by_user2)
    end

    it 'returns correct listings for  #all_listings' do
      membership = create(:membership, member: user, list: list_owned_by_user2)
      member_listing = create(:listing, list_id: list_owned_by_user2.id, user_id: user.id, movie_id: movie2.id )
      expect(user.all_listings).to include(listing)
      expect(user.all_listings).to include(member_listing)
    end

    it '#lists_except_movie' do
      movie2
      list2
      listing2
      expect(user.lists_except_movie(movie)).not_to include(list)
      expect(user.lists_except_movie(movie)).to include(list2)
    end

    it 'returns all lists if movie is not yet on a list' do
      list2
      expect(user.lists_except_movie).to match_array([list, list2])
    end

    describe '#all_movies and sorting' do
      let!(:membership) { create(:membership, member: user, list: list_owned_by_user2) }
      let!(:listing_on_member_list) { create(:listing, list_id: list_owned_by_user2.id, user_id: user.id, movie_id: movie2.id ) }
      let(:watched_movie) { create(:movie, title: 'watched_movie') }
      let!(:screening_user1) { create(:screening, user: user, movie: watched_movie) }
      let!(:screening_user2) { create(:screening, user: user2) }

      it '#all_movies' do
        expect(user.all_movies.pluck(:id)).to match_array([movie.id, movie2.id, watched_movie.id])
      end

      it '#all_movies_by_title' do
        movie.update(title: 'a christmas story')
        movie2.update(title: 'bad milo')
        watched_movie.update(title: 'cant buy me love')
        expect(user.all_movies_by_title.pluck(:id)).to eq([movie.id, movie2.id, watched_movie.id])
      end

      context 'by runtime' do
        before do
          movie.update(runtime: 10)
          movie2.update(runtime: 20)
          watched_movie.update(runtime: 30)
        end
        it '#all_movies_by_shortest_runtime' do
          expect(user.all_movies_by_shortest_runtime.pluck(:id)).to eq([movie.id, movie2.id, watched_movie.id])
        end

        it '#all_movies_by_longest_runtime' do
          expect(user.all_movies_by_longest_runtime.pluck(:id)).to eq([watched_movie.id, movie2.id, movie.id])
        end
      end

      it '#all_movies_by_recent_release_date' do
        movie.update(release_date: 3.years.ago)
        movie2.update(release_date: 2.years.ago)
        watched_movie.update(release_date: 1.year.ago)
        expect(user.all_movies_by_recent_release_date.pluck(:id)).to eq([watched_movie.id, movie2.id, movie.id])
      end

      it '#all_movies_by_highest_vote_average' do
        movie.update(vote_average: 7)
        movie2.update(vote_average: 8)
        watched_movie.update(vote_average: 9)
        expect(user.all_movies_by_highest_vote_average.pluck(:id)).to eq([watched_movie.id, movie2.id, movie.id])
      end

      it '#all_movies_by_recently_watched' do
        screening_user1.update(date_watched: 1.year.ago)
        create(:screening, user: user, movie: watched_movie, date_watched: 1.day.ago)
        create(:screening, user: user, movie: watched_movie, date_watched: 1.week.ago)
        create(:screening, user: user, movie: watched_movie, date_watched: 1.month.ago)
        create(:screening, user: user, movie: movie2, date_watched: 1.hour.ago)
        expect(user.screenings.pluck(:movie_id)).not_to include(movie.id)
        expect(user.all_movies_by_recently_watched.map(&:id)).to eq([movie2.id, watched_movie.id, movie.id])
      end

      it '#all_movies_not_on_a_list' do
        expect(user.all_movies_not_on_a_list.pluck(:id)).to match_array([movie2.id, watched_movie.id])
      end

      it '#all_movies_by_unwatched' do
        # secondary sort is by highest vote average
        movie.update(vote_average: 7)
        movie2.update(vote_average: 8)
        watched_movie.update(vote_average: 9)
        expect(user.all_movies_by_unwatched.map(&:id)).to eq([movie2.id, movie.id, watched_movie.id])
      end

      it '#all_movies_by_watched' do
        # secondary sort is by highest vote average
        movie.update(vote_average: 9)
        movie2.update(vote_average: 5)
        watched_movie.update(vote_average: 2)
        expect(user.all_movies_by_watched.map(&:id)).to eq([watched_movie.id, movie.id, movie2.id])
      end
    end
  end
  context 'without a valid factory' do
    it 'has an invalid factory' do
      expect(invalid_user).not_to be_valid
    end
  end
end
