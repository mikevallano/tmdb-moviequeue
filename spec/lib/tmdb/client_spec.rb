# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tmdb::Client do
  describe '.movie_autocomplete' do
    it 'returns a list of unique movie names' do
      parsed_data = {
        page: 1,
        results: [
          {:title=>'A'},
          {:title=>'A'},
          {:title=>'B'},
          {:title=>'C'}
        ]
      }
      allow(described_class).to receive(:fetch_parsed_response).and_return(parsed_data)
      names = described_class.movie_autocomplete("doesn't matter")
      expect(names).to eq(['A', 'B', 'C'])
    end
  end

  describe '.person_autocomplete' do
    it 'returns a list of unique actor names' do
      parsed_data = {
        page: 1,
        results: [
          {:media_type=>"movie", :original_title=>"Jennifer Lopez: Dance Again"},
          {:media_type=>"person", :name=>"Jennifer Lopez"},
          {:media_type=>"person", :name=>"Jennifer Gray"}
        ]
      }
      allow(described_class).to receive(:fetch_parsed_response).and_return(parsed_data)
      names = described_class.person_autocomplete("doesn't matter")
      expect(names).to eq(['Jennifer Lopez', 'Jennifer Gray'])
      expect(names).to_not include('Jennifer Lopez: Dance Again')
    end
  end

  # describe '.get_full_cast' do
  #   let(:parsed_data) do
  #     {
  #       page: 1,
  #       results: [
  #         {:media_type=>"movie", :original_title=>"Jennifer Lopez: Dance Again"},
  #         {:media_type=>"person", :name=>"Jennifer Lopez"},
  #         {:media_type=>"person", :name=>"Jennifer Gray"}
  #       ]
  #     }
  #   end
  #   before do
  #     allow(described_class).to receive(:fetch_parsed_response).and_return(parsed_data)
  #   end
  #
  #   xit 'returns movie data' do
  #   end
  #
  #   xit 'returns actor data' do
  #   end
  #
  #   xit 'returns director data' do
  #   end
  #
  #   xit 'returns editor data' do
  #   end
  # end

  describe 'person_detail_search' do
    before do
      allow(described_class).to receive(:fetch_parsed_response).and_return(parsed_data)
    end
    let(:parsed_data) do
      {
        page: 1,
        results: [
          {:media_type=>"movie", :original_title=>"Jennifer Lopez: Dance Again"},
          {:media_type=>"person", :name=>"Jennifer Lopez"},
          {:media_type=>"person", :name=>"Jennifer Gray"}
        ]
      }
    end

    let(:profile_data) do
      {:name=>"Patrick Stewart",
       :biography=>"An English film, television and stage actor.",
       :birthday=>"1940-07-13",
       :deathday=>nil,
       :id=>2387,
       :profile_path=>"/wEy5qSDT5jT3ZASc2hbwi59voPL.jpg"}
    end

    xit 'returns a person_id'
    xit 'returns profile data'
    xit 'returns movie credit data'
    xit 'returns tv credit data'
  end

  describe '.update_movie' do
  end

end
