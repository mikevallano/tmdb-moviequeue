# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovieDataService do
  let(:api) { Tmdb::Client }
  let(:movie_id) { 16320 }
  let(:parsed_movie_data) do
    { adult: false,
      backdrop_path: '/iEWkF.jpg',
      genres: [{ id: 878, name: 'Science Fiction' }],
      id: movie_id,
      imdb_id: 'tt0379786',
      overview: 'it got revers',
      popularity: 18.271,
      poster_path: '/ckDo.jpg',
      production_companies: [{ id: 33, logo_path: '/8lvHyhjr8oUKOOy2dKXoALWKdp0.png', name: 'Universal Pictures', origin_country: 'US' }],
      release_date: '2005-09-03',
      runtime: 119,
      title: 'Serenity',
      vote_average: 7.4,
      trailers: { youtube: [{ name: 'Serenity (2005) Trailer 1080p HD', size: 'HD', source: 'JY3u7bB7dZk', type: 'Trailer' }] },
      credits: {
        cast: [{ name: 'Nathan Fillion' }],
        crew: [
          { id: 12891, name: 'Joss Whedon', profile_path: '/onV5kv3.jpg', credit_id: '52fe46c59251416c75082fad', department: 'Directing', job: 'Director' },
          { id: 1018965, name: 'Lisa Lassek', profile_path: nil, credit_id: '52fe46c59251416c75083095', department: 'Editing', job: 'Editor' }
        ]
      },
      releases: { countries: [
        { certification: 'PG-13', iso_3166_1: 'US', primary: false, release_date: '2005-09-30' }
      ] } }
  end

  let(:discover_data) do
    {
      results: [parsed_movie_data],
      total_pages: 2,
      page: 1
    }
  end

  describe '.get_movie_title_search_results' do
    context 'when no results are found' do
      let(:searched_title) { 'kjdhfkgjfgh' }
      before do
        allow(api).to receive(:request).and_return(results: [])
      end

      it 'returns the movie_title' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.movie_title).to eq(searched_title)
      end

      it 'returns an object with a not-found message' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.not_found_message).to eq("No results for 'kjdhfkgjfgh'.")
      end

      it 'returns the string that was queried' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.query).to eq('kjdhfkgjfgh')
      end

      it 'returns nil for movies' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.movies).to eq(nil)
      end
    end

    context 'when results are found' do
      let(:searched_title) { 'star trek' }
      let(:parsed_results) do
        [
          { adult: false,
            backdrop_path: '/M3EvY.jpg',
            genre_ids: [878, 28, 12],
            id: 13475,
            original_language: 'en',
            original_title: 'Star Trek',
            overview: 'The fate of the galaxy rests...',
            popularity: 89.731,
            poster_path: '/ap1I35mH.jpg',
            release_date: '2009-05-06',
            title: 'Star Trek',
            video: false,
            vote_average: 7.4,
            vote_count: 8366 },
          { adult: false,
            backdrop_path: '/aRolAYEP.jpg',
            genre_ids: [878, 28, 12, 53],
            id: 201,
            original_language: 'en',
            original_title: 'Star Trek: Nemesis',
            overview: 'En route to the honeymoon of William Riker to Deanna Troi...',
            popularity: 21.403,
            poster_path: '/RHoXyq.jpg',
            release_date: '2002-12-13',
            title: 'Star Trek: Nemesis',
            video: false,
            vote_average: 6.3,
            vote_count: 1074 }
        ]
      end
      before do
        allow(api).to receive(:request).and_return(results: parsed_results)
      end

      it 'returns the movie_title' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.movie_title).to eq(searched_title)
      end

      it 'returns a not_found mesage that is nil' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.not_found_message).to eq(nil)
      end

      it 'returns a list of movie objects' do
        movies = described_class.get_movie_title_search_results(searched_title).movies
        expect(movies.first.title).to eq('Star Trek')
        expect(movies.second.title).to eq('Star Trek: Nemesis')
      end
    end
  end

  describe 'get_advanced_movie_search_results' do
    context 'when a valid actor name is provided' do
      it 'includes an actor in the search params' do
        allow(api).to receive(:request).with(:person_search, query: 'foo').and_return(results: [id: 1])
        expect(api).to receive(:request).with(:discover_search, people: 1).and_return(results: [])
        described_class.get_advanced_movie_search_results(actor_name: 'foo')
      end
    end

    context 'when an invalid actor name is provided' do
      it 'returns a not-found message about the actor name' do
        allow(api).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
        result = described_class.get_advanced_movie_search_results(actor_name: 'foo')
        expect(result.not_found_message).to eq("No results for actor 'foo'.")
      end
    end

    context 'when no movies matches are found' do
      it 'returns a not-found message about all of the searched terms' do
        stub_const('MovieDataService::GENRES', GENRES = [['foo', 42]].freeze)
        allow(api).to receive(:request).with(:discover_search, genre: 42).and_return(results: [])
        result = described_class.get_advanced_movie_search_results(genre: 42)
        expect(result.not_found_message).to eq('No results for foo movies.')
      end
    end

    context 'when movies matches are found' do
      let(:params) { {foo: 'bar'} }
      let(:person_name) { 'foo' }
      before do
        allow(api).to receive(:request).with(:discover_search, params).and_return(discover_data)
      end

      it 'returns movie data' do
        results = described_class.get_advanced_movie_search_results(params)
        expect(results.movies.length).to eq(1)
      end

      it 'returns pagination data' do
        results = described_class.get_advanced_movie_search_results(params)
        expect(results.page).to eq(1)
        expect(results.previous_page).to eq(nil)
        expect(results.current_page).to eq(1)
        expect(results.next_page).to eq(2)
        expect(results.total_pages).to eq(2)
      end

      context 'returning the searched arguments' do
        before do
          allow(api).to receive(:request).with(:person_search, query: person_name).and_return(person_data)
          allow(api).to receive(:request)
            .with(:discover_search, params.except(:actor_name).merge(people: 111))
            .and_return(discover_data)
        end
        let(:person_name) { 'Jeff' }
        let(:params) do
          {
            actor_name: person_name,
            company: 'JeffCo',
            date: '1990-01-01',
            genre: 42,
            mpaa_rating: 'R',
            sort_by: 45,
            timeframe: 'after',
            year: '1990'
          }
        end
        let(:person_data) { { results: [ id: 111 ] } }

        it 'returns the searched params' do
          results = described_class.get_advanced_movie_search_results(params)
          expect(results.searched_params).to eq(params)
        end

        it 'returns the searched terms in a human-readable format' do
          stub_const('MovieDataService::GENRES', GENRES = [['Action', 42]].freeze)
          stub_const('MovieDataService::SORT_BY', SORT_BY = [['Revenue', 45]].freeze)
          results = described_class.get_advanced_movie_search_results(params)
          expect(results.searched_terms).to eq('Jeff movies, Rated R, Action movies, after 1990, sorted by Revenue')
        end
      end
    end
  end

  describe '.get_movie_data' do
    it 'returns a MovieMore object with data' do
      allow(api).to receive(:request).and_return(parsed_movie_data)
      movie = described_class.get_movie_data(movie_id)
      expect(movie.title).to eq('Serenity')
      expect(movie.overview).to eq('it got revers')
    end
  end

  describe '.get_movie_cast' do
    before do
      allow(api).to receive(:request).and_return(parsed_movie_data)
    end

    it 'returns movie data' do
      cast = described_class.get_movie_cast(movie_id)
      expect(cast.movie.title).to eq('Serenity')
    end

    it 'returns actor data' do
      cast = described_class.get_movie_cast(movie_id)
      expect(cast.actors.first.name).to eq('Nathan Fillion')
    end

    it 'returns director data' do
      cast = described_class.get_movie_cast(movie_id)
      expect(cast.directors.first.name).to eq('Joss Whedon')
    end

    it 'returns editor data' do
      cast = described_class.get_movie_cast(movie_id)
      expect(cast.editors.first.name).to eq('Lisa Lassek')
    end
  end

  describe '.get_movie_titles' do
    it 'returns a list of unique movie names' do
      parsed_data = [
        { title: 'A' },
        { title: 'A' },
        { title: 'B' },
        { title: 'C' }
      ]
      allow(api).to receive(:request).and_return(results: parsed_data)
      names = described_class.get_movie_titles("doesn't matter")
      expect(names).to eq(%w[A B C])
    end
  end

  describe '.get_common_movies_between_multiple_actors' do
    let(:actor1_id) { 1743 }
    let(:actor1_name) { 'Denise Crosby' }
    let(:actor_1_results) { { results: [{ id: actor1_id, name: actor1_name }] } }
    let(:actor2_id) { 11065 }
    let(:actor2_name) { 'Wilford Brimley' }
    let(:actor_2_results) do
      { results: [{ id: actor2_id, name: actor2_name }] }
    end
    let(:no_common_movies_response) { { page: 1, results: [], total_pages: 0, total_results: 0 } }
    let(:movie_title) { 'Mutant Species' }
    let(:common_movies_results) do
      { page: 1,
        results: [{ adult: false,
                    backdrop_path: nil,
                    genre_ids: [27, 878],
                    id: 114540,
                    original_title: movie_title,
                    poster_path: '/wdWit3RNCo90HrwiNAGlHo0W5h6.jpg',
                    release_date: '1995-01-19',
                    title: movie_title,
                    vote_count: 7 }],
        total_pages: 1,
        total_results: 1 }
    end
    context 'when 1 actor isnt found' do
      it 'returns a not-found message for that actor' do
        allow(api).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
        results = described_class.get_common_movies_between_multiple_actors(actor_names: ['foo'])
        expect(results.not_found_message).to eq("No actor found for 'foo'.")
      end
    end

    context 'when both actors are not found' do
      it 'returns a not-found messages for each missing actor' do
        allow(api).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
        allow(api).to receive(:request).with(:person_search, query: 'bar').and_return(results: [])
        results = described_class.get_common_movies_between_multiple_actors(actor_names: %w[foo bar])
        expect(results.not_found_message).to eq("No actor found for 'foo'. No actor found for 'bar'.")
      end
    end

    context 'when both actors are found but share no movies' do
      it 'returns a message saying there are no results for these actors' do
        allow(api).to receive(:request).with(:person_search, query: actor1_name).and_return(actor_1_results)
        allow(api).to receive(:request).with(:person_search, query: actor2_name).and_return(actor_2_results)
        allow(api).to receive(:request)
          .with(:discover_search, page: nil, people: "#{actor1_id},#{actor2_id}", sort_by: nil)
          .and_return(no_common_movies_response)
        results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
        expect(results.not_found_message).to eq("No results for movies with #{actor1_name} and #{actor2_name}.")
      end
    end

    context 'when both actors are found and share movies' do
      before do
        allow(api).to receive(:request).with(:person_search, query: actor1_name).and_return(actor_1_results)
        allow(api).to receive(:request).with(:person_search, query: actor2_name).and_return(actor_2_results)
        allow(api).to receive(:request)
          .with(:discover_search, page: nil, people: "#{actor1_id},#{actor2_id}", sort_by: nil)
          .and_return(common_movies_results)
      end

      it 'returns the actor names' do
        results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
        expect(results.actor_names).to eq([actor1_name, actor2_name])
      end

      it 'has no not-found messaging' do
        results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
        expect(results.not_found_message).to eq(nil)
      end

      it 'returns a MovieSearchResult object with movie data' do
        results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
        expect(results.common_movies.length).to eq(common_movies_results[:results].length)
        expect(results.common_movies.first.title).to eq(movie_title)
      end
    end
  end

  describe '.update_movie' do
    let(:movie) { create(:movie_in_tmdb) }
    let(:tmdb_id) { movie.tmdb_id }
    subject { MovieDataService.update_movie(movie) }

    context 'with a valid movie' do
      it 'returns true' do
        VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie') do
          expect(subject).to eq(true)
        end
      end

      it 'updates the movie' do
        VCR.use_cassette('tmdb_handler_update_movie_with_a_valid_movie') do
          expect { subject }.to(change { movie.reload.updated_at })
        end
      end
    end

    context 'when no movie found from api response' do
      before { movie.update(tmdb_id: 'wrong') }
      it 'raises an error and does not update the movie' do
        VCR.use_cassette('tmdb_handler_update_movie_with_an_invalid_movie') do
          expect { subject }.not_to(change { movie.reload.updated_at })
        end
      end
    end

    context 'when the title does not match' do
      before { movie.update(title: 'Fargowrong') }
      it 'does not raise an error' do
        VCR.use_cassette('tmdb_handler_update_movie_with_wrong_title') do
          expect { subject }.not_to raise_error
        end
      end

      it 'still updates the movie' do
        VCR.use_cassette('tmdb_handler_update_movie_with_wrong_title') do
          expect { subject }.to(change { movie.reload.updated_at })
        end
      end
    end

    context 'with outdated info' do
      let(:wrong_mpaa_rating) { 'G' }
      let(:correct_mpaa_rating) { 'R' }
      before { movie.update(mpaa_rating: wrong_mpaa_rating) }
      it 'updates movie with latest tmdb info' do
        VCR.use_cassette('tmdb_handler_update_movie_with_outdated_info') do
          subject
          expect(movie.reload.mpaa_rating).to eq(correct_mpaa_rating)
        end
      end
    end
  end
end
