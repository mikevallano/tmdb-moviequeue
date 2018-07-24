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

  describe '#movie_stats_display' do
    let(:current_user) { create(:user) }
    let(:movie) { create(:movie,
                          title: "Free Chickens",
                          release_date: "2015-12-07",
                          vote_average: 7.5,
                          runtime: 120,
                          mpaa_rating: "R"
                )}

    it 'renders the release_date, mpaa_rating, runtime, and star_rating' do
      expect(movie_stats_display(movie)).to eq("2015 | R | 2hr | 7.5 ★")
    end

    it 'does not include empty pipes `|`' do
      movie.runtime = nil
      expect(movie_stats_display(movie)).to eq("2015 | R | 7.5 ★")
    end

    it "shows current user's rating if there is one" do
      response = movie_stats_display(movie)
      expect(response).not_to include('Me')

      create(:rating, user: current_user, movie: movie, value: 7)
      response = movie_stats_display(movie)
      expect(response).to include('Me')
    end
  end

  describe '#movie_genres_display' do
    let(:genre_list) { ['Action', 'Comedy', 'Romance'] }

    it 'displays links to the genres for a movie' do
      movie.genres = genre_list
      expect(movie_genres_display(movie)).to include('<a href="/genres/Action">Action</a>')
    end

  end

  describe '#runtime_display' do
    let(:movie) { create(:movie, runtime: 190)}
    it 'displays hours and minutes' do
      expect(runtime_display(movie)).to eq('3hr 10min')
    end

    it 'displays only hours when the minute-count is divisible by 60' do
      movie.runtime = 120
      expect(runtime_display(movie)).to eq('2hr')
    end

    it 'displays nothing if there is no runtime' do
      movie.runtime = nil
      expect(runtime_display(movie)).to eq(nil)
    end
  end

end
