require 'rails_helper'

describe MoviesHelper, type: :helper do

  let(:movie) { create(:movie) }

  describe 'move poster image_for' do
    it "renders the movie missing poster partial" do
      allow(movie).to receive(:poster_path).and_return(nil)
      allow(helper).to receive(:render)
      helper.image_for(movie)
      expect(helper).to have_received(:render).with("movies/movie_missing_poster", movie: movie)
    end

    it 'returns an image tag if the movie has a poster path' do
      allow(movie).to receive(:poster_path).and_return('tester')
      expect(helper.image_for(movie)).to eq(image_tag("http://image.tmdb.org/t/p/w185#{movie.poster_path}"))
    end
  end

  describe '#link_to_movie' do
    it 'returns the correct link path when movie is not in db' do
      allow(movie).to receive(:in_db).and_return(false)
      expect(helper.link_to_movie(movie)).to eq(movie_more_path(tmdb_id: movie.tmdb_id))
    end

    it 'returns the correct link path when movie is in db' do
      allow(movie).to receive(:in_db).and_return(true)
      expect(helper.link_to_movie(movie)).to eq(movie_path(movie))
    end
  end

  describe 'trailer placeholder text' do
    it 'renders correct placeholder text for a movie with a trailer' do
      allow(movie).to receive(:trailer).and_return('trailerlink')
      expect(helper.trailer_placeholder_text(movie)).to include('change the trailer')
    end

    it 'renders correct placeholder text for a movie without a trailer' do
      allow(movie).to receive(:trailer).and_return(nil)
      expect(helper.trailer_placeholder_text(movie)).to include('add a trailer')
    end
  end

  describe 'trailer button text' do
    it 'renders correct button text for a movie with a trailer' do
      allow(movie).to receive(:trailer).and_return('trailerlink')
      expect(helper.trailer_button_text(movie)).to eq('Change trailer')
    end

    it 'renders correct button text for a movie without a trailer' do
      allow(movie).to receive(:trailer).and_return(nil)
      expect(helper.trailer_button_text(movie)).to eq('Add a trailer')
    end
  end

end
