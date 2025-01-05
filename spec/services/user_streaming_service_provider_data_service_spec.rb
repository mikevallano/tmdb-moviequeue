# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserStreamingServiceProviderDataService do
  describe 'check_availability_for_title' do
    let(:user) { create(:user) }
    let(:movie_title) { 'Fake' }
    let(:movie) { build(:movie, title: movie_title, release_date: '2023-01-01') }
    let(:method_arguments) do
      {
        user: user,
        tmdb_id: movie.tmdb_id,
        title: movie.title,
        media_type: 'movie',
        media_format: 'movie',
        release_date: movie.release_date
      }
    end

    context "when the user has no providers selected" do
      it 'returns a struct with empty arrays and an error message' do
        providers = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
        expect(providers.free).to eq([])
        expect(providers.rent).to eq([])
        expect(providers.buy).to eq([])
        expect(providers.not_found).to eq([])
        expect(providers.no_providers_selected.present?).to be(true)
      end
    end

    context "when the user has selected providers" do
      let(:netflix_provider) { StreamingServiceProvider.find("5a871334-7e1c-4e3a-9d3c-ba4bf9a3bc7c") }
      let(:amazon_provider) { StreamingServiceProvider.find("94fd2937-745b-4cbc-ac7a-a53fa1fdf1a6") }
      let(:amazon_prime_provider) { StreamingServiceProvider.find("b9444a73-d374-45fd-8098-8d340b047d73") }
      let(:fandango_provider) { StreamingServiceProvider.find("b2c97df4-7178-4c05-bdcd-7a6e5794bd9c") }
      let(:youtube_provider) { StreamingServiceProvider.find("0c517786-369c-431f-8d45-4e72a26b1cb2") }
      
      before do
        user.user_streaming_service_providers.create(streaming_service_provider_id: netflix_provider.id)
        user.user_streaming_service_providers.create(streaming_service_provider_id: amazon_provider.id)
        user.user_streaming_service_providers.create(streaming_service_provider_id: amazon_prime_provider.id)
        user.user_streaming_service_providers.create(streaming_service_provider_id: fandango_provider.id)
        user.user_streaming_service_providers.create(streaming_service_provider_id: youtube_provider.id)
      end
      
      describe 'when the API does not return any data' do
        it 'returns an open struct with empty arrays for each pay model' do
          allow(Tmdb::Client).to receive(:request).and_return(nil)
  
          providers = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
          expect(providers.free).to eq([])
          expect(providers.rent).to eq([])
          expect(providers.buy).to eq([])
          expect(providers.not_found).to eq([])
        end
      end
  
      describe 'when the API does return results' do
        let(:netflix_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 8, provider_name: "Netflix", display_priority: 26} }
        let(:amazon_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 10, provider_name: "Amazon Video", display_priority: 26} }
        let(:amazon_prime_api_data) { {logo_path: "/5OAb2w.jpg", provider_id: 9, provider_name: "Amazon Prime Video", display_priority: 25} }
        let(:youtube_api_data) { {logo_path: "/xL9SUR.jpg", provider_id: 192, provider_name: "YouTube", display_priority: 51} }
        let(:fandango_api_data) { {logo_path: "/peURlL.jpg", provider_id: 7, provider_name: "Fandango At Home", display_priority: 4} }
  
        describe 'but the results do not have free, flatrate, rent, or buy pay model options' do
          it "returns the user's default providers as 'not_found'" do
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
  
            providers = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expected_provider_names = user.streaming_service_providers.map(&:display_name)
            returned_provider_names = providers.not_found.map(&:display_name)
            expect(expected_provider_names).to match_array(returned_provider_names)
          end
        end
  
        describe 'but none of the preferred_providers are represented in the free, flatrate, rent, or buy options' do
          it "returns the user's default providers as 'not_found'" do
            response_data = {
              results: {
                US: {
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
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            providers = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expected_provider_names = user.streaming_service_providers.map(&:display_name)
            returned_provider_names = providers.not_found.map(&:display_name)
            expect(expected_provider_names).to match_array(returned_provider_names)
          end
        end
  
        describe 'when a user-selected provider appears in the results for this movies free options' do
          it 'returns this provider in the "free" data' do
            response_data = {
              results: {
                US: {
                  free:
                    [netflix_api_data]
                }
              }
            }
  
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.free.map(&:tmdb_provider_id)).to include(netflix_api_data[:provider_id])
          end
        end
  
        describe 'when a user-selected provider appears in the results for this movies flatrate options' do
          it 'returns this flatrate provider in the "free" data' do
            response_data = {
              results: {
                US: {
                  flatrate:
                    [netflix_api_data]
                }
              }
            }
  
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)

            expect(results.free.map(&:tmdb_provider_id)).to include(netflix_api_data[:provider_id])
          end
        end
  
        describe 'when a user-selected provider appears in the results for this movies rent options' do
          it 'returns this provider in the "rent" data' do
            response_data = {
              results: {
                US: {
                  rent:
                    [amazon_api_data]
                }
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.rent).to include(amazon_provider)
          end
        end
  
        describe 'when a user-selected provider appears in the results for this movies buy options' do
          it 'returns this provider in the "buy" data' do
            response_data = {
              results: {
                US: {
                  buy:
                    [amazon_api_data]
                }
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.buy).to include(amazon_provider)
          end
        end
  
        describe 'when a user-selected provider does not appear in the results for any pay model options' do
          let(:selected_provider) { fandango_provider }
          it 'returns this provider in the "not_found" data' do
            response_data = {
              results: {
                US: {
                  flatrate:
                    [netflix_api_data]
                }
              }
            }

            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
  
            expect(results.not_found).to include(fandango_provider)
          end
        end
  
        describe 'when the same provider appears in the results for free and rent pay models' do
          let(:response_data) do
            {
              results: {
                US: {
                  flatrate:
                    [amazon_api_data],
                  rent:
                    [amazon_api_data],
                }
              }
            }
          end

          it 'returns this provider in the "free" data' do
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.free.map(&:tmdb_provider_id)).to include(amazon_api_data[:provider_id])
          end

          it 'does not include this provider in the "rent" data' do
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.rent.map(&:tmdb_provider_id)).to_not include(amazon_api_data[:provider_id])
          end
        end
  
        describe 'when the same provider appears in the results for rent and buy pay models' do
          let(:response_data) do
            {
              results: {
                US: {
                  buy:
                    [amazon_api_data],
                  rent:
                    [amazon_api_data],
                }
              }
            }
          end

          it 'returns the provider with a pay model of "rent"' do
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.rent).to include(amazon_provider)
          end

          it 'does not include this provider in the "buy" data' do
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            expect(results.buy).to_not include(amazon_provider)
          end
        end
  
        describe 'when multiple user-selected providers appear in multiple categories' do
          it "returns each provider with preferring free, then rent, then buy, and then 'not_found' for ones that weren't found" do
            response_data = {
              results: {
                US: {
                  flatrate:
                    [netflix_api_data, fandango_api_data],
                  rent:
                    [fandango_api_data, amazon_api_data],
                  buy:
                    [fandango_api_data, amazon_api_data, youtube_api_data],
                }
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)

            aggregate_failures "expected pay model levels per provider" do
              expect(results.free.map(&:tmdb_provider_id)).to include(netflix_api_data[:provider_id])
              expect(results.free.map(&:tmdb_provider_id)).to include(fandango_api_data[:provider_id])
              expect(results.rent.map(&:tmdb_provider_id)).to include(amazon_api_data[:provider_id])
              expect(results.buy.map(&:tmdb_provider_id)).to include(youtube_api_data[:provider_id])

              expect(results.rent.map(&:tmdb_provider_id)).to_not include(fandango_api_data[:provider_id])
              expect(results.buy.map(&:tmdb_provider_id)).to_not include(fandango_api_data[:provider_id])
              expect(results.buy.map(&:tmdb_provider_id)).to_not include(amazon_api_data[:provider_id])
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
  
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**method_arguments)
            aggregate_failures "expecting to not find any of these non-user-selected providers" do
              expect(results.free.map(&:tmdb_provider_name)).to_not include("Foo")
              expect(results.buy.map(&:tmdb_provider_name)).to_not include("Bar")
              expect(results.rent.map(&:tmdb_provider_name)).to_not include("Baz")
            end
          end
        end
  
        describe 'when searching for providers for a TV series' do
          let(:tv_args) do
            {
              user: user,
              tmdb_id: 'foo',
              title: 'foo',
              media_type: 'tv',
              media_format: 'episodes'
            }
          end
    
          it "returns each provider with preferring free, then rent, then buy, and then 'not_found' for ones that weren't found" do
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
            results = UserStreamingServiceProviderDataService.check_availability_for_title(**tv_args)
    
            aggregate_failures "expected pay_model levels per provider" do
              expect(results.free.map(&:tmdb_provider_id)).to include(netflix_api_data[:provider_id])
              expect(results.not_found.map(&:tmdb_provider_id)).to include(amazon_prime_api_data[:provider_id])
              expect(results.rent.map(&:tmdb_provider_id)).to include(amazon_api_data[:provider_id])
              expect(results.buy.map(&:tmdb_provider_id)).to include(youtube_api_data[:provider_id])
              expect(results.free.map(&:tmdb_provider_id)).to include(fandango_api_data[:provider_id])
            end
          end
        end
      end
    end
  end
end
