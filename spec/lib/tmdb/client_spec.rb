# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tmdb::Client do
  describe 'request' do
    let(:empty_result_set) { { results: [] } }

    describe 'when there are empty params provided' do
      it 'returns an empty result set' do
        expect(Tmdb::Client.request('foo_endpoint', {})).to eq(empty_result_set)
      end
    end

    describe 'when there are no params provided' do
      it 'returns an empty result set' do
        expect(Tmdb::Client.request('foo_endpoint', nil)).to eq(empty_result_set)
      end
    end

    describe 'when :query params key is present' do
      describe 'and the value is an empty string' do
        it 'returns an empty result set' do
          expect(Tmdb::Client.request('foo_endpoint', { query: '' })).to eq(empty_result_set)
        end
      end

      describe 'and the string has searchable characters' do
        it 'makes the request' do
          params = { query: 'Sandra Bullock' }
          allow(JSON).to receive(:parse).and_return('success')
          expect(Tmdb::Client.request('foo_endpoint', params)).to eq('success')
        end
      end

      describe 'but the string does not contain searchable characters' do
        it 'returns an empty result set' do
          expect(Tmdb::Client.request('foo_endpoint', { query: '&!*' })).to eq(empty_result_set)
        end
      end
    end

    describe 'when keys other than :query are present' do
      params = { people: 18277, page: nil, sort_by: "" }
      it 'makes the request' do
        allow(JSON).to receive(:parse).and_return('success')
        expect(Tmdb::Client.request('foo_endpoint', params)).to eq('success')
      end
    end
  end

  describe 'private.build_url' do
    context 'when a user searches for a bunch non-alphanumeric characters as a query string' do
      let(:searched_string) { '&^%$#@#$%' }
      it 'does not send those characters to the API' do
        params = [:person_search, {query: searched_string}]
        url = described_class.send(:build_url, *params)
        expect(url).to_not include(searched_string)
      end
    end

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
end
