# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tmdb::Client do
  describe 'any method that uses a query search string' do
    context 'when a user searches for a bunch non-alphanumeric characters' do
      let(:searched_title) { '&^%$#@#$%' }
      it 'returns no movie results' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.movies).to be(nil)
      end

      it 'returns a not-found message' do
        results = described_class.get_movie_title_search_results(searched_title)
        expect(results.not_found_message).to eq("No results for '#{searched_title}'.")
      end
    end
  end

  describe 'movie methods' do
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
          allow(described_class).to receive(:request).and_return(results: [])
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
          allow(described_class).to receive(:request).and_return(results: parsed_results)
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
          allow(described_class).to receive(:request).with(:person_search, query: 'foo').and_return(results: [id: 1])
          expect(described_class).to receive(:request).with(:discover_search, people: 1).and_return(results: [])
          described_class.get_advanced_movie_search_results(actor_name: 'foo')
        end
      end

      context 'when an invalid actor name is provided' do
        it 'returns a not-found message about the actor name' do
          allow(described_class).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
          result = described_class.get_advanced_movie_search_results(actor_name: 'foo')
          expect(result.not_found_message).to eq("No results for actor 'foo'.")
        end
      end

      context 'when no movies matches are found' do
        it 'returns a not-found message about all of the searched terms' do
          stub_const('MovieDataService::GENRES', GENRES = [['foo', 42]].freeze)
          allow(described_class).to receive(:request).with(:discover_search, genre: 42).and_return(results: [])
          result = described_class.get_advanced_movie_search_results(genre: 42)
          expect(result.not_found_message).to eq('No results for foo movies.')
        end
      end

      context 'when movies matches are found' do
        let(:params) { {foo: 'bar'} }
        let(:person_name) { 'foo' }
        before do
          allow(described_class).to receive(:request).with(:discover_search, params).and_return(discover_data)
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
            allow(described_class).to receive(:request).with(:person_search, query: person_name).and_return(person_data)
            allow(described_class).to receive(:request)
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
            # allow(described_class).to receive(:request).with(:person_search, query: person_name).and_return(person_data)
            # allow(described_class).to receive(:request)
            #   .with(:discover_search, params.except(:actor_name).merge(people: 111))
            #   .and_return(discover_data)
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

    describe 'private.build_url' do
      context 'when year is provided and no timeframe is given' do
        it 'includes an exact year in the query string' do
          params = [:discover_search, {year: '1980'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&primary_release_year=1980')
        end
      end

      context "when 'year' and a 'timeframe' of 'exact' is provided" do
        it 'defaults to "exact"' do
          params = [:discover_search, {year: '1980', timeframe: 'exact'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&primary_release_year=1980')
        end
      end

      context "when 'year' and a 'timeframe' of 'before' is provided" do
        it 'includes the less-than date in the API query string' do
          params = [:discover_search, {year: '1980', timeframe: 'before'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&primary_release_date.lte=1980-01-01')
        end
      end

      context "when 'year' and a 'timeframe' of 'after' is provided" do
        it 'includes the the greater than date in the API query string' do
          params = [:discover_search, {year: '1980', timeframe: 'after'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&primary_release_date.gte=1980-12-31')
        end
      end

      context 'when "people" is provided' do
        it 'includes the genre in the API query string' do
          params = [:discover_search, {people: 42}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&with_people=42')
        end
      end

      context 'when "genre" is provided' do
        it 'includes the genre in the API query string' do
          params = [:discover_search, {genre: 42}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&with_genres=42')
        end
      end

      context 'when rating is provided' do
        it 'includes the rating in the API query string' do
          params = [:discover_search, {mpaa_rating: 'foo'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&certification=foo')
        end
      end

      context 'when sort-by is provided' do
        it 'includes the sort-by the API query string' do
          params = [:discover_search, {sort_by: 'foo'}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&sort_by=foo.desc')
        end
      end

      context 'when sort-by is not provided' do
        it 'defaults to "popularity"' do
          params = [:discover_search, {}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&sort_by=popularity.desc')
        end
      end

      context 'when "page" is provided' do
        it 'includes the page in the API query string' do
          params = [:discover_search, {page: 2}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&page=2')
        end
      end

      context 'when "page" is not provided' do
        it 'defaults to page 1 in the API query string' do
          params = [:discover_search, {}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&page=1')
        end
      end

      context 'when multiple params are provided' do
        it 'includes them all' do
          params = [:discover_search, {sort_by: 'foo', genre: 28, mpaa_rating: 'R', year: 2021, timeframe: 'after', page: 2}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&with_genres=28&certification=R&sort_by=foo.desc&page=2&primary_release_date.gte=2021-12-31')
        end
      end

      context 'when no params are provided' do
        it 'still includes certification, page, and sort-by' do
          params = [:discover_search, {}]
          url = described_class.send(:build_url, *params)
          expect(url).to include('&certification_country=US&sort_by=popularity.desc&page=1')
        end
      end
    end

    describe '.get_movie_data' do
      it 'returns a MovieMore object with data' do
        allow(described_class).to receive(:request).and_return(parsed_movie_data)
        movie = described_class.get_movie_data(movie_id)
        expect(movie.title).to eq('Serenity')
        expect(movie.overview).to eq('it got revers')
      end
    end

    describe '.get_movie_cast' do
      before do
        allow(described_class).to receive(:request).and_return(parsed_movie_data)
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
        allow(described_class).to receive(:request).and_return(results: parsed_data)
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
          allow(described_class).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
          results = described_class.get_common_movies_between_multiple_actors(actor_names: ['foo'])
          expect(results.not_found_message).to eq("No actor found for 'foo'.")
        end
      end

      context 'when both actors are not found' do
        it 'returns a not-found messages for each missing actor' do
          allow(described_class).to receive(:request).with(:person_search, query: 'foo').and_return(results: [])
          allow(described_class).to receive(:request).with(:person_search, query: 'bar').and_return(results: [])
          results = described_class.get_common_movies_between_multiple_actors(actor_names: %w[foo bar])
          expect(results.not_found_message).to eq("No actor found for 'foo'. No actor found for 'bar'.")
        end
      end

      context 'when both actors are found but share no movies' do
        it 'returns a message saying there are no results for these actors' do
          allow(described_class).to receive(:request).with(:person_search, query: actor1_name).and_return(actor_1_results)
          allow(described_class).to receive(:request).with(:person_search, query: actor2_name).and_return(actor_2_results)
          allow(described_class).to receive(:request)
            .with(:discover_search, page: nil, people: "#{actor1_id},#{actor2_id}", sort_by: nil)
            .and_return(no_common_movies_response)
          results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
          expect(results.not_found_message).to eq("No results for movies with #{actor1_name} and #{actor2_name}.")
        end
      end

      context 'when both actors are found and share movies' do
        before do
          allow(described_class).to receive(:request).with(:person_search, query: actor1_name).and_return(actor_1_results)
          allow(described_class).to receive(:request).with(:person_search, query: actor2_name).and_return(actor_2_results)
          allow(described_class).to receive(:request)
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

        it 'returns a MovieSearch object with movie data' do
          results = described_class.get_common_movies_between_multiple_actors(actor_names: [actor1_name, actor2_name])
          expect(results.common_movies.length).to eq(common_movies_results[:results].length)
          expect(results.common_movies.first.title).to eq(movie_title)
        end
      end
    end
  end

  describe 'person methods' do
    describe '.get_person_names' do
      it 'returns a list of unique actor names' do
        parsed_data = [
          { media_type: 'movie', original_title: 'Jennifer Lopez: Dance Again' },
          { media_type: 'person', name: 'Jennifer Lopez' },
          { media_type: 'person', name: 'Jennifer Gray' }
        ]
        allow(described_class).to receive(:request).and_return(results: parsed_data)
        names = described_class.get_person_names("doesn't matter")
        expect(names).to eq(['Jennifer Lopez', 'Jennifer Gray'])
        expect(names).to_not include('Jennifer Lopez: Dance Again')
      end
    end

    describe '.get_person_profile_data' do
      let(:person_id) { '2387' }
      let(:person_bio_data) do
        { name: 'Patrick Stewart',
          biography: 'An English film, television and stage actor.',
          birthday: '1940-07-13',
          deathday: nil,
          id: person_id,
          profile_path: '/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg' }
      end

      let(:person_movie_credit_data) do
        {
          id: person_id,
          cast: [
            { adult: false,
              backdrop_path: '/aBMLpWsWXPOoTnbK37VKuQA0q0s.jpg',
              genre_ids: [878, 28, 12, 53],
              id: 193,
              original_language: 'en',
              original_title: 'Star Trek: Generations',
              overview: "Captain Jean-Luc Picard and the crew of the Enterprise-D find themselves at odds with the renegade scientist Soran who is destroying entire star systems. Only one man can help Picard stop Soran's scheme...and he's been dead for seventy-eight years.",
              poster_path: '/rHsCYDGHFUarGh5k987b0EFU6kC.jpg',
              release_date: '1994-11-18',
              title: 'Star Trek: Generations',
              video: false,
              vote_average: 6.5,
              vote_count: 992,
              popularity: 11.808,
              character: 'Captain Jean-Luc Picard',
              credit_id: '52fe4225c3a36847f80076d9',
              order: 0 }
          ],
          crew: [
            { adult: false,
              backdrop_path: '/xkgoxCfvLJeaA7LT7ewL9T0rMvC.jpg',
              genre_ids: [35],
              id: 84340,
              original_language: 'en',
              original_title: 'Sleepwalk with Me',
              overview: 'A burgeoning stand-up comedian struggles with the stress of a stalled career, a stale relationship, and the wild spurts of severe sleepwalking he is desperate to ignore.',
              poster_path: '/vs2wxfMrV48VWKTGbsYstIWrwI1.jpg',
              release_date: '2012-08-24',
              title: 'Sleepwalk with Me',
              video: false,
              vote_average: 6.6,
              vote_count: 139,
              popularity: 7.158,
              credit_id: '52fe48ed9251416c9109cf3b',
              department: 'Directing',
              job: 'Director' },
            { poster_path: '/9pbc44kltJhArUNyrdQcantMEvH.jpg',
              video: false,
              vote_average: 6.4,
              overview: "When an alien race and factions within Starfleet attempt to take over a planet that has \"regenerative\" properties, it falls upon Captain Picard and the crew of the Enterprise to defend the planet's people as well as the very ideals upon which the Federation itself was founded.",
              release_date: '1998-12-11',
              id: 200,
              adult: false,
              backdrop_path: '/goNk0VDnUjxKjB6o69kYS5vvZo2.jpg',
              vote_count: 888,
              genre_ids: [878, 28, 12, 53],
              title: 'Star Trek: Insurrection',
              original_language: 'en',
              original_title: 'Star Trek: Insurrection',
              popularity: 17.228,
              credit_id: '52fe4226c3a36847f8007c1d',
              department: 'Production',
              job: 'Producer' },
            { adult: false,
              backdrop_path: '/llT1qYnBy0AC0F3EZbYl97knchI.jpg',
              genre_ids: [35],
              id: 55804,
              original_language: 'en',
              original_title: 'What I Should Have Said Was Nothing',
              overview: 'Mike says, "A few years ago my therapist suggested I keep a journal of all the crazy things that were going on in my life, so that I could keep things in perspective. Around the same time audiences were demanding more material, and I realized that other people might enjoy these stories-so I started sending them out to my mailing list. Now, my Secret Public Journal has become a Comedy Central special and DVD for all the world to see. Not sure this is what my therapist had in mind."',
              poster_path: '/mRHqImaRNU096gEyiE0lMZqW5I4.jpg',
              release_date: '2008-02-09',
              title: 'What I Should Have Said Was Nothing',
              video: false,
              vote_average: 7.5,
              vote_count: 31,
              popularity: 3.845,
              credit_id: '52fe48e1c3a36847f817e659',
              department: 'Writing',
              job: 'Writer' },
            { adult: false,
              backdrop_path: '/wXNOOPJQjGm8NerPjjl8L3Xm50W.jpg',
              genre_ids: [35],
              id: 18480,
              original_language: 'en',
              original_title: 'Brüno',
              overview: 'Flamboyantly gay Austrian television reporter Bruno stirs up trouble with unsuspecting guests and large crowds through brutally frank interviews and painfully hilarious public displays of homosexuality.',
              poster_path: '/xLFYL5gwCPnMDp5Qmd5wiRSsRPX.jpg',
              release_date: '2009-07-08',
              title: 'Brüno',
              video: false,
              vote_average: 5.6,
              vote_count: 1324,
              popularity: 14.085,
              credit_id: '54c02fae9251416e9b0099ca',
              department: 'Editing',
              job: 'Editor' }
          ]
        }
      end

      let(:person_tv_credit_data) do
        {
          id: person_id,
          cast: [
            { first_air_date: '1953-03-18',
              id: 27023,
              name: 'The Oscars',
              poster_path: '/wF43fJ8D85i79ZrLZsnUZ2JurbP.jpg',
              character: 'Self',
              credit_id: '52588354760ee3466140b6a5' }
          ],
          crew: [
            { original_name: 'Kath & Kim',
              id: 15131,
              name: 'Kath & Kim',
              vote_count: 2,
              vote_average: 6.0,
              first_air_date: '2008-10-09',
              poster_path: '/oPoSygZTburk4aeyvV5lFE5T9GL.jpg',
              genre_ids: [35],
              original_language: 'en',
              backdrop_path: '/cuqbFcvHnjFhMQNybyJ2CH8SHxK.jpg',
              overview: "Kath & Kim is an American version of the Australian television comedy series of the same name starring Selma Blair and Molly Shannon. The series premiered on NBC on October 9, 2008. The Australian version was created by its original stars, Jane Turner and Gina Riley, who also serve as executive producers and consultants on this version as well, which is co-produced through Reveille Productions and Universal Media Studios.\n\nIts first episode premiered in Australia on Sunday, October 12 on the Seven Network and its Australian broadcast was cancelled after the second episode the following week. The series was then pushed to a graveyard slot of 11pm Mondays, and then pre-empted for the 2009 Australian Open after the first-run airing of episode 9, \"Friends\". Although the show initially garnered unremarkable ratings and mixed reviews from critics, NBC picked up Kath & Kim for a full season order of 22 episodes on October 31, 2008. On January 15, 2009, NBC cut the episode order from 22 to 17 episodes. The show's season finale aired on March 12, 2009. On May 19, 2009, NBC confirmed the series cancellation.",
              origin_country: ['US'],
              popularity: 5.558,
              credit_id: '54c02fe39251416e9b0099d0',
              department: 'Editing',
              episode_count: 2,
              job: 'Editor' },
            { poster_path: '/qIvBbZ1yq3tzIXKqhU3VxYPbizF.jpg',
              first_air_date: '2019-06-12',
              id: 83074,
              vote_average: 6.5,
              overview: "U.S. police chief Bill Hixon lands in the British town of Boston, Lincolnshire, with his 14-year-old daughter Kelsey in tow hoping they can flee their painful recent past. But this unfamiliar, unimpressed community will force Bill to question everything about himself and leave him asking whether it's Boston that needs Bill, or Bill that needs Boston?",
              name: 'Wild Bill',
              original_name: 'Wild Bill',
              origin_country: ['GB'],
              vote_count: 14,
              genre_ids: [18, 35, 80],
              backdrop_path: '/odsxbvsSi0tv3bI37b5gtU0BWen.jpg',
              original_language: 'en',
              popularity: 7.156,
              credit_id: '5bc198a792514179ca02822d',
              department: 'Production',
              episode_count: 6,
              job: 'Executive Producer' },
            { backdrop_path: '/yYaxXMbobcB7PIM6XljZZk2x4FQ.jpg',
              name: 'Saturday Night Live',
              genre_ids: [35, 10763],
              original_name: 'Saturday Night Live',
              origin_country: ['US'],
              first_air_date: '1975-10-11',
              poster_path: '/bfiBW2qtdPEdcDOhYGNiP8XX8ok.jpg',
              id: 1667,
              vote_average: 6.9,
              overview: 'A late-night live television sketch ',
              vote_count: 295,
              original_language: 'en',
              popularity: 78.621,
              credit_id: '52570fdb760ee3776a0b1a09',
              department: 'Writing',
              episode_count: 181,
              job: 'Writer' },
            { name: 'Laverne & Shirley',
              original_name: 'Laverne & Shirley',
              origin_country: ['US'],
              vote_count: 44,
              backdrop_path: '/1zLn6Ou9dJ0jzrKtkPGZ95OIahc.jpg',
              vote_average: 7.5,
              genre_ids: [35],
              id: 3033,
              original_language: 'en',
              overview: 'American television sitcom that ran on ABC from January 27, 1976 to May 10, 1983.',
              poster_path: '/1w6v2Uq5qvjlFq3eQQLXxzAHvh9.jpg',
              first_air_date: '1976-01-27',
              popularity: 19.368,
              credit_id: '52574b66760ee36aaa13c246',
              department: 'Directing',
              episode_count: 1,
              job: 'Director' }
          ]
        }
      end

      before do
        allow(described_class).to receive(:request).with(:person_data, person_id: person_id).and_return(person_bio_data)
        allow(described_class).to receive(:request).with(:person_movie_credits, person_id: person_id).and_return(person_movie_credit_data)
        allow(described_class).to receive(:request).with(:person_tv_credits, person_id: person_id).and_return(person_tv_credit_data)
      end

      it 'returns a person_id' do
        person = described_class.get_person_profile_data(person_id)
        expect(person.person_id).to eq(person_id)
      end

      it 'returns profile data' do
        person = described_class.get_person_profile_data(person_id)
        expect(person.profile.person_id).to eq(person_id)
        expect(person.profile.name).to eq('Patrick Stewart')
        expect(person.profile.profile_path).to eq('/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg')
        expect(person.profile.bio).to include('An English film')
        expect(person.profile.birthday).to eq('1940-07-13')
      end

      it 'returns movie credit data' do
        person = described_class.get_person_profile_data(person_id)
        expect(person.movie_credits).to be_instance_of(MoviePersonCredits)
        expect(person.movie_credits.actor.first.character).to eq('Captain Jean-Luc Picard')
        expect(person.movie_credits.directing.first.title).to eq('Sleepwalk with Me')
        expect(person.movie_credits.editing.first.credit_id).to eq('54c02fae9251416e9b0099ca')
        expect(person.movie_credits.writing.first.credit_id).to eq('52fe48e1c3a36847f817e659')
        expect(person.movie_credits.screenplay).to eq([])
        expect(person.movie_credits.producer.first.department).to eq('Production')
      end

      it 'returns tv credit data' do
        person = described_class.get_person_profile_data(person_id)
        expect(person.tv_credits).to be_instance_of(TVPersonCredits)
        expect(person.tv_credits.actor.first.character).to eq('Self')
        expect(person.tv_credits.directing.first.show_name).to eq('Laverne & Shirley')
        expect(person.tv_credits.editing.first.show_name).to eq('Kath & Kim')
        expect(person.tv_credits.writing.first.credit_id).to eq('52570fdb760ee3776a0b1a09')
        expect(person.tv_credits.screenplay).to eq([])
        expect(person.tv_credits.producer.first.show_name).to eq('Wild Bill')
      end
    end
  end

  describe 'tv methods' do
    describe '.get_actor_tv_appearance_credits' do
      let(:parsed_credits) do
        {
          media: {
            name: 'The Good Place',
            id: 66573,
            character: 'Doug Forcett',
            episodes: [{ air_date: '2018-11-15',
                         episode_number: 8,
                         id: 1593085,
                         name: "Don't Let The Good Life Pass You By",
                         overview: 'Michael and Janet visit the person.',
                         production_code: '',
                         season_number: 3,
                         show_id: 66573,
                         still_path: '/7wZBtiIlcTPekf3KiyKn1wwD6DQ.jpg',
                         vote_average: 7.526,
                         vote_count: 19 }],
            seasons: [{ air_date: '2018-09-27',
                        episode_count: 12,
                        id: 105508,
                        name: 'Season 3',
                        overview: '',
                        poster_path: '/3dJDT1dVSuHBYqWD0OLT1ZXeLq7.jpg',
                        season_number: 3,
                        show_id: 66573 }]
          },
          person: {
            name: 'Michael McKean',
            id: 21731,
            profile_path: '/xuEZeuylzznJcf0nDs1RlvuzaPr.jpg',
            known_for: [{ backdrop_path: '/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg',
                          id: 456.0,
                          genre_ids: [10751.0, 16.0, 35.0],
                          original_language: 'en',
                          media_type: 'tv',
                          poster_path: '/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg',
                          popularity: 765.151,
                          vote_count: 7531.0,
                          vote_average: 7.9,
                          original_name: 'The Simpsons',
                          origin_country: ['US'],
                          overview: 'Set in Springfield, the average American town.',
                          name: 'The Simpsons',
                          first_air_date: '1989-12-17' }]
          }
        }
      end
      before do
        allow(described_class).to receive(:request).and_return(parsed_credits)
      end

      it 'returns tv_actor_credit data' do
        person = described_class.get_actor_tv_appearance_credits('foo')
        expect(person).to be_instance_of(TVActorCredit)
        expect(person.actor_id).to eq(21731)
        expect(person.actor_name).to eq('Michael McKean')
        expect(person.character).to eq('Doug Forcett')
        expect(person.episodes.first.episode_number).to eq(8)
        expect(person.known_for.first[:name]).to eq('The Simpsons')
        expect(person.profile_path).to eq('/xuEZeuylzznJcf0nDs1RlvuzaPr.jpg')
        expect(person.show_id).to eq(66573)
        expect(person.show_name).to eq('The Good Place')
        expect(person.seasons.first.air_date).to eq('9/27/2018')
      end
    end

    describe '.get_tv_series_names' do
      let(:parsed_tv_search_results) do
        [{ id: 2382, name: 'Freaks and Geeks' },
         { id: 97018, name: 'Freaks!' }]
      end

      it 'returns a list of only Series names' do
        allow(described_class).to receive(:request).and_return(results: parsed_tv_search_results)
        suggestions = described_class.get_tv_series_names('foo')
        expect(suggestions).to eq(['Freaks and Geeks', 'Freaks!'])
      end
    end

    describe '.get_tv_series_search_results' do
      let(:parsed_tv_search_results) do
        [{
          backdrop_path: '/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg',
          first_air_date: '1989-12-17',
          genre_ids: [10751, 16, 35],
          id: 456,
          name: 'The Simpsons',
          origin_country: ['US'],
          original_language: 'en',
          original_name: 'The Simpsons',
          overview: 'Set in Springfield.',
          popularity: 707.512,
          poster_path: '/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg',
          vote_average: 7.9,
          vote_count: 7536
        }]
      end
      before do
        allow(described_class).to receive(:request).and_return(results: parsed_tv_search_results)
      end
      it 'returns an array of TVSeries objects with data' do
        series = described_class.get_tv_series_search_results('foo').first
        expect(series.show_id).to eq(456)
        expect(series.first_air_date).to eq('12/17/1989')
        expect(series.last_air_date).to eq(nil)
        expect(series.show_name).to eq('The Simpsons')
        expect(series.backdrop_path).to eq('/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg')
        expect(series.poster_path).to eq('/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg')
        expect(series.number_of_episodes).to eq(nil)
        expect(series.number_of_seasons).to eq(nil)
        expect(series.overview).to eq('Set in Springfield.')
        expect(series.seasons).to eq(nil)
        expect(series.actors).to eq(nil)
      end
    end

    describe '.get_tv_series_data' do
      let(:parsed_tv_series_data) do
        {
          backdrop_path: '/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg',
          first_air_date: '1989-12-17',
          genre_ids: [10751, 16, 35],
          id: 456,
          name: 'The Simpsons',
          number_of_seasons: 7,
          origin_country: ['US'],
          original_language: 'en',
          original_name: 'The Simpsons',
          overview: 'Set in Springfield.',
          popularity: 707.512,
          poster_path: '/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg',
          vote_average: 7.9,
          vote_count: 7536,
          credits: {
            cast: [
              { adult: false,
                gender: 2,
                id: 2387,
                known_for_department: 'Acting',
                name: 'Patrick Stewart',
                original_name: 'Patrick Stewart',
                popularity: 16.35,
                profile_path: '/5FBzMRNy65vV9RzibBBwW4p6lUq.jpg',
                character: 'Jean-Luc Picard',
                credit_id: '52538dc019c2957940268e14',
                order: 0 }
            ]
          }
        }
      end
      before do
        allow(described_class).to receive(:request).and_return(parsed_tv_series_data)
      end
      it 'returns a TVSeries object with data' do
        series = described_class.get_tv_series_data('foo')
        expect(series.show_id).to eq('foo')
        expect(series.first_air_date).to eq('12/17/1989')
        expect(series.last_air_date).to eq(nil)
        expect(series.show_name).to eq('The Simpsons')
        expect(series.backdrop_path).to eq('/hpU2cHC9tk90hswCFEpf5AtbqoL.jpg')
        expect(series.poster_path).to eq('/tubgEpjTUA7t0kejVMBsNBZDarZ.jpg')
        expect(series.number_of_episodes).to eq(nil)
        expect(series.number_of_seasons).to eq(7)
        expect(series.overview).to eq('Set in Springfield.')
        expect(series.seasons).to eq([1, 2, 3, 4, 5, 6, 7])
        expect(series.actors.first.name).to eq('Patrick Stewart')
      end
    end

    describe '.get_tv_season_data' do
      let(:tv_series) { build(:tv_series, show_id: 1) }
      let(:parsed_tv_season_data) do
        {
          _id: '52538d0319c2957940260d67',
          air_date: '1990-09-24',
          id: 1991,
          name: 'Season 4',
          overview: 'Riker tries to save the Enterprise and the Earth',
          production_code: '40274-175',
          season_number: 4,
          still_path: '/12345.jpg',
          poster_path: '/67891.jpg',
          vote_average: 8.194,
          vote_count: 31,
          credits: {
            cast: [
              { adult: false,
                gender: 2,
                id: 2388,
                known_for_department: 'Acting',
                name: 'Jonathan Frakes',
                original_name: 'Jonathan Frakes',
                popularity: 7.206,
                profile_path: '/koY6DtPAnuiJpdOW3bPHzmoC6cZ.jpg',
                character: 'William T. Riker',
                credit_id: '52538dc019c2957940268e42',
                order: 1 }
            ]
          },
          episodes: [{ air_date: '1990-09-30',
                       episode_number: 2,
                       crew: [{ department: 'Directing',
                                job: 'Director',
                                credit_id: '52538d0819c2957940261261',
                                adult: false,
                                gender: 2,
                                id: 1219320,
                                known_for_department: 'Directing',
                                name: 'Cliff Bole',
                                original_name: 'Cliff Bole',
                                popularity: 0.771,
                                profile_path: nil }] }]
        }
      end
      it 'returns a TVSeason object with data' do
        allow(described_class).to receive(:request).and_return(parsed_tv_season_data)
        season = described_class.get_tv_season_data(series: tv_series, season_number: 'foo')

        expect(season.series.show_id).to eq(1)
        expect(season.show_id).to eq(1)
        expect(season.air_date).to eq('1990-09-24'.to_date)
        expect(season.name).to eq('Season 4')
        expect(season.overview).to eq('Riker tries to save the Enterprise and the Earth')
        expect(season.season_id).to eq(1991)
        expect(season.season_id).to eq(1991)
        expect(season.poster_path).to eq('/67891.jpg')
        expect(season.season_number).to eq(4)
        expect(season.credits[:cast].first[:name]).to eq('Jonathan Frakes')
        expect(season.cast_members.first.name).to eq('Jonathan Frakes')
        expect(season.episodes.first.air_date.to_s).to eq('1990-09-30')
      end
    end

    describe '.get_tv_episode_data' do
      let(:tv_series) { build(:tv_series, show_id: 1) }
      let(:parsed_tv_episode_data) do
        {
          air_date: '1990-10-08',
          episode_number: 3,
          guest_stars: [{ character: "Chief O'Brien",
                          credit_id: '52538d0819c29579402612c4',
                          order: 1,
                          adult: false,
                          gender: 2,
                          id: 17782,
                          known_for_department: 'Acting',
                          name: 'Colm Meaney',
                          original_name: 'Colm Meaney',
                          popularity: 9.629,
                          profile_path: '/guL6RJdlRMtOJN3LoaY3G8hG4Rd.jpg' }],
          name: 'Brothers',
          overview: 'Data mysteriously takes control of the Enterprise.',
          id: 37107,
          season_number: 4,
          still_path: '/QfGzs.jpg'
        }
      end
      it 'returns a TVEpisode object with data' do
        allow(described_class).to receive(:request).and_return(parsed_tv_episode_data)
        episode = described_class.get_tv_episode_data(series_id: tv_series.show_id, season_number: 'foo', episode_number: 'foo')
        expect(episode.episode_id).to eq(37107)
        expect(episode.episode_number).to eq(3)
        expect(episode.name).to eq('Brothers')
        expect(episode.air_date).to eq('1990-10-08'.to_date)
        expect(episode.guest_stars.first.name).to eq('Colm Meaney')
        expect(episode.season_number).to eq(4)
        expect(episode.overview).to eq('Data mysteriously takes control of the Enterprise.')
        expect(episode.still_path).to eq('/QfGzs.jpg')
      end
    end
  end
end
