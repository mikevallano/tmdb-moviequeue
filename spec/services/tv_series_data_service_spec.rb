# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TvSeriesDataService do
  let(:api) { Tmdb::Client }

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
      allow(api).to receive(:request).and_return(parsed_credits)
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
      allow(api).to receive(:request).and_return(results: parsed_tv_search_results)
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
      allow(api).to receive(:request).and_return(results: parsed_tv_search_results)
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
      allow(api).to receive(:request).and_return(parsed_tv_series_data)
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
      allow(api).to receive(:request).and_return(parsed_tv_season_data)
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
      allow(api).to receive(:request).and_return(parsed_tv_episode_data)
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
