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


end
