# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StreamingServiceProviderDataService do
  describe 'get_providers' do
    let(:movie_title) { 'Fake' }
    let(:movie) { build(:movie, title: movie_title, release_date: '2023-01-01') }
    let(:movie_args) do
      {
        tmdb_id: movie.tmdb_id,
        title: movie.title,
        media_type: 'movie',
        media_format: 'movie',
        release_date: movie.release_date
      }
    end

    describe 'when the API does not return any data' do
      it 'returns our default providers with a pay_model of "try"' do
        allow(Tmdb::Client).to receive(:request).and_return(nil)

        providers = StreamingServiceProviderDataService.get_providers(**movie_args)
        try_pay_models = providers.select {|provider| provider[:pay_model] == 'try'}
        expect(providers.length).to eq(try_pay_models.length)
      end
    end

    describe 'when the API does return results' do
      let(:netflix_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 8, provider_name: "Netflix", display_priority: 26} }
      let(:amazon_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 10, provider_name: "Amazon Video", display_priority: 26} }
      let(:amazon_prime_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 9, provider_name: "Amazon Prime Video", display_priority: 25} }
      let(:youtube_api_data) { {logo_path: "/xL9SUR.jpg", provider_id: 192, provider_name: "YouTube", display_priority: 51} }
      let(:fandango_api_data) { {logo_path: "/peURlL.jpg", provider_id: 7, provider_name: "Fandango At Home", display_priority: 4} }

      describe 'but the results do not have free, flatrate, rent, or buy pay model options' do
        it 'returns our default providers with a pay_model of "try"' do
          response_data = {
            results: {
              US: {
                ads:
                  [netflix_api_data, amazon_api_data, youtube_api_data],
                subscribe:
                  [fandango_api_data, amazon_prime_api_data],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          providers = StreamingServiceProviderDataService.get_providers(**movie_args)
          try_pay_models = providers.select {|provider| provider[:pay_model] == 'try'}
          expect(providers.length).to eq(try_pay_models.length)
        end
      end

      describe 'but none of the preferred_providers are represented in the free, flatrate, rent, or buy options' do
        it 'returns our default providers with a pay_model of "try"' do
          response_data = {
            free:
              [{logo_path: "/5OAb2w.jpg", provider_id: 634, provider_name: "Starz Roku Premium Channel", display_priority: 26}],
            flatrate:
              [{logo_path: "/5OAb2w.jpg", provider_id: 634, provider_name: "Starz Roku Premium Channel", display_priority: 26}],
            buy:
              [{logo_path: "/peURlL.jpg", provider_id: 2, provider_name: "Apple iTunes", display_priority: 4},
              {logo_path: "/kJlVJL.jpg", provider_id: 352, provider_name: "AMC on Demand", display_priority: 130}],
            rent:
              [{logo_path: "/peURlL.jpg", provider_id: 2, provider_name: "Microsoft Store", display_priority: 4},
              {logo_path: "/kJlVJL.jpg", provider_id: 352, provider_name: "Google Play Movies", display_priority: 130}]
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          providers = StreamingServiceProviderDataService.get_providers(**movie_args)
          try_pay_models = providers.select {|provider| provider[:pay_model] == 'try'}
          expect(providers.length).to eq(try_pay_models.length)
        end
      end

      describe 'when a preferred provider appears in the results for this movies free options' do
        it 'returns this provider with a pay_model of "free"' do
          response_data = {
            results: {
              US: {
                free:
                  [netflix_api_data]
              }
            }
          }

          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == netflix_api_data[:provider_name]}[:pay_model] ).to eq('free')
        end
      end

      describe 'when a preferred provider appears in the results for this movies flatrate options' do
        it 'returns this provider with a pay_model of "free"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [netflix_api_data]
              }
            }
          }

          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == netflix_api_data[:provider_name]}[:pay_model] ).to eq('free')
        end
      end

      describe 'when a preferred provider appears in the results for this movies rent options' do
        it 'returns this provider with a pay_model of "rent"' do
          response_data = {
            results: {
              US: {
                rent:
                  [amazon_api_data]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == amazon_api_data[:provider_name]}[:pay_model] ).to eq('rent')
        end
      end

      describe 'when a preferred provider appears in the results for this movies buy options' do
        it 'returns this provider with a pay_model of "buy"' do
          response_data = {
            results: {
              US: {
                buy:
                  [amazon_api_data]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == amazon_api_data[:provider_name]}[:pay_model] ).to eq('buy')
        end

      end

      describe 'when a preferred provider does not appear in the results for any pay model options' do
        it 'returns this provider with a pay_model of "try"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [netflix_api_data]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == fandango_api_data[:provider_name]}[:pay_model] ).to eq('try')
        end
      end

      describe 'when the same provider appears in the results for free and rent pay models' do
        it 'returns the provider with a pay model of "free"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [fandango_api_data],
                rent:
                  [fandango_api_data],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == fandango_api_data[:provider_name]}[:pay_model] ).to eq('free')
        end
      end

      describe 'when the same provider appears in the results for rent and buy pay models' do
        it 'returns the provider with a pay model of "rent"' do
          response_data = {
              results: {
                US: {
                  buy:
                  [fandango_api_data],
                  rent:
                  [fandango_api_data],
                }
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = StreamingServiceProviderDataService.get_providers(**movie_args)

          expect(results.find {|r| r[:tmdb_provider_name] == fandango_api_data[:provider_name]}[:pay_model] ).to eq('rent')
        end
      end

      describe 'when multiple preferred providers appear in multiple categories' do
        it "returns each provider with preferring free, then rent, then buy, and then 'try' for ones that weren't found" do
          response_data = {
            results: {
              US: {
                flatrate:
                  [netflix_api_data, fandango_api_data],
                buy:
                  [fandango_api_data, amazon_api_data, youtube_api_data],
                rent:
                  [fandango_api_data,  amazon_api_data],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**movie_args)

          aggregate_failures "expected pay_model levels per provider" do
            expect(results.find {|r| r[:tmdb_provider_name] == netflix_api_data[:provider_name]}[:pay_model] ).to eq('free')
            expect(results.find {|r| r[:tmdb_provider_name] == amazon_prime_api_data[:provider_name]}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:tmdb_provider_name] == amazon_api_data[:provider_name]}[:pay_model] ).to eq('rent')
            expect(results.find {|r| r[:tmdb_provider_name] == youtube_api_data[:provider_name]}[:pay_model] ).to eq('buy')
            expect(results.find {|r| r[:tmdb_provider_name] == fandango_api_data[:provider_name]}[:pay_model] ).to eq('free')
          end
        end
      end

      describe 'when the API results contain streaming services that are not listed in the preferred_providers list' do
        it 'does not display them in the list' do
         response_data = {
            results: {
              US: {
                flatrate:
                  [{logo_path: "/eWp5Ld.jpg", provider_id: 1, provider_name: "Foo", display_priority: 38}],
                buy:
                  [{logo_path: "/eWp5Ld.jpg", provider_id: 2, provider_name: "Bar", display_priority: 38}],
                rent:
                  [{logo_path: "/eWp5Ld.jpg", provider_id: 3, provider_name: "Baz", display_priority: 38}]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          results = StreamingServiceProviderDataService.get_providers(**movie_args)
          aggregate_failures "expecting to not find any of these non-preferred providers" do
            expect(results.find {|r| r[:tmdb_provider_name] == 'Foo'}).to be(nil)
            expect(results.find {|r| r[:tmdb_provider_name] == 'Bar'}).to be(nil)
            expect(results.find {|r| r[:tmdb_provider_name] == 'Baz'}).to be(nil)
          end
        end
      end

      describe 'when searching for providers for a TV series' do
        let(:tv_args) do
          {
            tmdb_id: 'foo',
            title: 'foo',
            media_type: 'tv',
            media_format: 'episodes'
          }
        end
  
        it "returns each provider with preferring free, then rent, then buy, and then 'try' for ones that weren't found" do
          response_data = {
            results: {
              US: {
                free:
                  [fandango_api_data],
                flatrate:
                  [netflix_api_data],
                buy:
                  [fandango_api_data, amazon_api_data, youtube_api_data],
                rent:
                  [fandango_api_data, amazon_api_data],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(**tv_args)
  
          aggregate_failures "expected pay_model levels per provider" do
            expect(results.find {|r| r[:tmdb_provider_name] == netflix_api_data[:provider_name]}[:pay_model] ).to eq('free')
            expect(results.find {|r| r[:tmdb_provider_name] == amazon_prime_api_data[:provider_name]}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:tmdb_provider_name] == amazon_api_data[:provider_name]}[:pay_model] ).to eq('rent')
            expect(results.find {|r| r[:tmdb_provider_name] == youtube_api_data[:provider_name]}[:pay_model] ).to eq('buy')
            expect(results.find {|r| r[:tmdb_provider_name] == fandango_api_data[:provider_name]}[:pay_model] ).to eq('free')
          end
        end
      end
    end
  end
end
