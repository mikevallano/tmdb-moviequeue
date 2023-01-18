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

        results = StreamingServiceProviderDataService.get_providers(movie_args)
        aggregate_failures "all default providers appear with 'try'" do
          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('try')
          expect(results.find {|r| r[:name] == 'Amazon Prime Video'}[:pay_model] ).to eq('try')
          expect(results.find {|r| r[:name] == 'Amazon Video'}[:pay_model] ).to eq('try')
          expect(results.find {|r| r[:name] == 'YouTube'}[:pay_model] ).to eq('try')
          expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('try')
        end
      end
    end

    describe 'when the API does return results' do
      describe 'but the results do not have free, flatrate, rent, or buy pay model options' do
        it 'returns our default providers with a pay_model of "try"' do
          response_data = {
            results: {
              US: {
                ads:
                  [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Netflix", :display_priority=>26},
                  {:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"Amazon Video", :display_priority=>38},
                  {:logo_path=>"/xL9SUR.jpg", :provider_id=>358, :provider_name=>"YouTube", :display_priority=>51}],
                subscribe:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4},
                  {:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Amazon Prime Video", :display_priority=>4}],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          results = StreamingServiceProviderDataService.get_providers(movie_args)
          aggregate_failures "all default providers appear with 'try'" do
            expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Amazon Prime Video'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Amazon Video'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'YouTube'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('try')
          end
        end
      end

      describe 'but none of the preferred_providers are represented in the free, flatrate, rent, or buy options' do
        it 'returns our default providers with a pay_model of "try"' do
          response_data = {
            free:
              [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Starz Roku Premium Channel", :display_priority=>26}],
            flatrate:
              [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Starz Roku Premium Channel", :display_priority=>26}],
            buy:
              [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Apple iTunes", :display_priority=>4},
              {:logo_path=>"/kJlVJL.jpg", :provider_id=>352, :provider_name=>"AMC on Demand", :display_priority=>130}],
            rent:
              [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Microsoft Store", :display_priority=>4},
              {:logo_path=>"/kJlVJL.jpg", :provider_id=>352, :provider_name=>"Google Play Movies", :display_priority=>130}]
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          results = StreamingServiceProviderDataService.get_providers(movie_args)
          aggregate_failures "all default providers appear with 'try'" do
            expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Amazon Prime Video'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Amazon Video'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'YouTube'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('try')
          end
        end
      end

      describe 'when a preferred provider appears in the results for this movies free options' do
        it 'returns this provider with a pay_model of "free"' do
          response_data = {
            results: {
              US: {
                free:
                  [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Netflix", :display_priority=>26}]
              }
            }
          }

          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('free')
        end
      end

      describe 'when a preferred provider appears in the results for this movies flatrate options' do
        it 'returns this provider with a pay_model of "free"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Netflix", :display_priority=>26}]
              }
            }
          }

          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('free')
        end
      end

      describe 'when a preferred provider appears in the results for this movies rent options' do
        it 'returns this provider with a pay_model of "rent"' do
          response_data = {
            results: {
              US: {
                rent:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Netflix", :display_priority=>4}]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('rent')
        end
      end

      describe 'when a preferred provider appears in the results for this movies buy options' do
        it 'returns this provider with a pay_model of "buy"' do
          response_data = {
            results: {
              US: {
                buy:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Netflix", :display_priority=>4}]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('buy')
        end

      end

      describe 'when a preferred provider does not appears in the results for any pay model options' do
        it 'returns this provider with a pay_model of "try"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Netflix", :display_priority=>4}]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('try')
        end
      end

      describe 'when the same provider appears in the results for free and rent pay models' do
        it 'returns the provider with a pay model of "free"' do
          response_data = {
            results: {
              US: {
                flatrate:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4}],
                rent:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4}],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('free')
        end
      end

      describe 'when the same provider appears in the results for rent and buy pay models' do
        it 'returns the provider with a pay model of "rent"' do
          response_data = {
              results: {
                US: {
                  buy:
                    [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4}],
                  rent:
                    [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4}],
                }
              }
            }
            allow(Tmdb::Client).to receive(:request).and_return(response_data)
            results = StreamingServiceProviderDataService.get_providers(movie_args)

            expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('rent')
        end
      end

      describe 'when multiple preferred providers appear in multiple categories' do
        it "returns each provider with preferring free, then rent, then buy, and then 'try' for ones that weren't found" do
          response_data = {
            results: {
              US: {
                flatrate:
                  [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Netflix", :display_priority=>26},
                  {:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"Vudu", :display_priority=>38}],
                buy:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4},
                  {:logo_path=>"/5NyLm4.jpg", :provider_id=>10, :provider_name=>"Amazon Video", :display_priority=>12},
                  {:logo_path=>"/oIkQkE.jpg", :provider_id=>192, :provider_name=>"YouTube", :display_priority=>14}],
                rent:
                  [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4},
                  {:logo_path=>"/5NyLm4.jpg", :provider_id=>10, :provider_name=>"Amazon Video", :display_priority=>12}],
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)
          results = StreamingServiceProviderDataService.get_providers(movie_args)

          aggregate_failures "expected pay_model levels per provider" do
            expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('free')
            expect(results.find {|r| r[:name] == 'Amazon Prime Video'}[:pay_model] ).to eq('try')
            expect(results.find {|r| r[:name] == 'Amazon Video'}[:pay_model] ).to eq('rent')
            expect(results.find {|r| r[:name] == 'YouTube'}[:pay_model] ).to eq('buy')
            expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('free')
          end
        end
      end

      describe 'when the API results contain streaming services that are not listed in the preferred_providers list' do
        it 'does not display them in the list' do
         response_data = {
            results: {
              US: {
                flatrate:
                  [{:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"Starz", :display_priority=>38}],
                buy:
                  [{:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"Google Play Movies", :display_priority=>38}],
                rent:
                  [{:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"AMC on Demand", :display_priority=>38}]
              }
            }
          }
          allow(Tmdb::Client).to receive(:request).and_return(response_data)

          results = StreamingServiceProviderDataService.get_providers(movie_args)
          aggregate_failures "expecting to not find any of these non-preferred providers" do
            expect(results.find {|r| r[:name] == 'Starz'}).to be(nil)
            expect(results.find {|r| r[:name] == 'Google Play Movies'}).to be(nil)
            expect(results.find {|r| r[:name] == 'AMC on Demand'}).to be(nil)
          end
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
                [{:logo_path=>"/eWp5Ld.jpg", :provider_id=>43, :provider_name=>"Vudu", :display_priority=>38}],
              flatrate:
                [{:logo_path=>"/5OAb2w.jpg", :provider_id=>634, :provider_name=>"Netflix", :display_priority=>26}],
              buy:
                [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4},
                {:logo_path=>"/5NyLm4.jpg", :provider_id=>10, :provider_name=>"Amazon Video", :display_priority=>12},
                {:logo_path=>"/oIkQkE.jpg", :provider_id=>192, :provider_name=>"YouTube", :display_priority=>14}],
              rent:
                [{:logo_path=>"/peURlL.jpg", :provider_id=>2, :provider_name=>"Vudu", :display_priority=>4},
                {:logo_path=>"/5NyLm4.jpg", :provider_id=>10, :provider_name=>"Amazon Video", :display_priority=>12}],
            }
          }
        }
        allow(Tmdb::Client).to receive(:request).and_return(response_data)
        results = StreamingServiceProviderDataService.get_providers(tv_args)

        aggregate_failures "expected pay_model levels per provider" do
          expect(results.find {|r| r[:name] == 'Netflix'}[:pay_model] ).to eq('free')
          expect(results.find {|r| r[:name] == 'Amazon Prime Video'}[:pay_model] ).to eq('try')
          expect(results.find {|r| r[:name] == 'Amazon Video'}[:pay_model] ).to eq('rent')
          expect(results.find {|r| r[:name] == 'YouTube'}[:pay_model] ).to eq('buy')
          expect(results.find {|r| r[:name] == 'Vudu'}[:pay_model] ).to eq('free')
        end

      end
    end
  end
end
