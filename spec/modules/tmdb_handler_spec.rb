require 'rails_helper'

RSpec.describe TmdbHandler, type: :module do
  let(:movie) { create(:movie_in_tmdb) }
  let(:tmdb_id) { movie.tmdb_id }
  subject { TmdbHandler.tmdb_handler_update_movie(tmdb_id) }

  context 'with a valid movie' do
    it 'returns true' do
      VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie', record: :new_episodes) do
        expect(subject).to eq(true)
      end
    end

    it 'updates the movie' do
      VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie', record: :new_episodes) do
        expect{ subject }.to change{ movie.reload.updated_at }
      end
    end
  end

  context 'when movie is not found in db' do
    let(:tmdb_id) { 'wrong' }
    it { is_expected.to be_nil }
    it { expect{subject}.not_to change{ movie.reload.updated_at } }
  end

  context 'when no movie found from api response' do
    before { movie.update(tmdb_id: 'wrong')}
    it 'returns nil' do
      VCR.use_cassette('tmdb_handler_update_movie_with_an_invalid_movie', record: :new_episodes) do
        expect(subject).to be_nil
      end
    end

    it 'does not update the movie' do
      VCR.use_cassette('tmdb_handler_update_movie_with_an_invalid_movie', record: :new_episodes) do
        expect{ subject }.not_to change{ movie.reload.updated_at }
      end
    end
  end

  context 'when the title does not match' do
    before { movie.update(title: 'Fargowrong') }
    it 'returns nil' do
      VCR.use_cassette('tmdb_handler_update_movie_with_wrong_title', record: :new_episodes) do
        expect(subject).to be_nil
      end
    end

    it 'does not update the movie' do
      VCR.use_cassette('tmdb_handler_update_movie_with_wrong_title', record: :new_episodes) do
        expect{ subject }.not_to change{ movie.reload.updated_at }
      end
    end
  end

  context 'with outdated info' do
    let(:wrong_mpaa_rating) { 'G' }
    let(:correct_mpaa_rating) { 'R' }
    before { movie.update(mpaa_rating: wrong_mpaa_rating) }
    it 'updates movie with latest tmdb info' do
      VCR.use_cassette('tmdb_handler_update_movie_with_outdated_info', record: :new_episodes) do
        subject
        expect(movie.reload.mpaa_rating).to eq(correct_mpaa_rating)
      end
    end
  end

  context 'when the movie fails to save' do
    let(:dupe_movie) { build(:movie, tmdb_id: movie.tmdb_id) }
    before { dupe_movie.save(validate: false) }

    it 'returns nil' do
      VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie', record: :new_episodes) do
        expect(subject).to be_nil
      end
    end
  end

  context 'when tmdb_id is passed as a string' do
    let(:tmdb_id) { movie.tmdb_id.to_s }

    it 'returns true' do
      VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie', record: :new_episodes) do
        expect(subject).to eq(true)
      end
    end
  end
end
