# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovieSuggestionService do
  let(:user) { create(:user, username: 'mike') }
  let(:partner) { create(:user, username: 'partner') }
  let(:list) { create(:list, owner: user, name: 'Esta Noche') }
  let!(:membership) { create(:membership, list: list, member: partner) }

  let(:on_list) { create(:movie, title: 'Heat', tmdb_id: 949, release_date: '1995-12-15') }
  let!(:listing) { create(:listing, list: list, movie: on_list, user: user) }

  def tmdb_result(id:, title:, year:)
    { id: id, title: title, release_date: "#{year}-06-01", poster_path: "/#{id}.jpg", vote_average: 7.0 }
  end

  def stub_tmdb(title, results)
    allow(Tmdb::Client).to receive(:request)
      .with(:movie_search, { query: title }, described_class::TMDB_LOOKUP_TIMEOUT)
      .and_return(results: results)
  end

  def stub_claude(suggestions)
    allow(Claude::Client).to receive(:request_json).and_return(suggestions: suggestions)
  end

  describe '.get_suggestions' do
    it "uses only the user's taste when there is no list" do
      stub_claude([])

      described_class.get_suggestions(user: user, query: 'anything')

      expect(Claude::Client).to have_received(:request_json) do |prompt:, **|
        expect(prompt).to include('# Taste: mike (the person asking)')
        expect(prompt).not_to include('# Taste: partner')
      end
    end

    it "uses the owner's and members' taste when there is a list" do
      stub_claude([])

      described_class.get_suggestions(user: partner, list: list)

      expect(Claude::Client).to have_received(:request_json) do |prompt:, **|
        expect(prompt).to include('# Taste: mike')
        expect(prompt).to include('# Taste: partner (the person asking)')
      end
    end

    it 'returns TMDB-matched suggestions with reasons' do
      stub_claude([{ title: 'Thief', year: 1981, reason: 'Michael Mann heist' }])
      stub_tmdb('Thief', [tmdb_result(id: 11_524, title: 'Thief', year: 1981)])

      results = described_class.get_suggestions(user: user, list: list)

      expect(results.movies.map(&:tmdb_id)).to eq([11_524])
      expect(results.movies.first.reason).to eq('Michael Mann heist')
      expect(results.not_found_message).to be_nil
    end

    it 'drops suggestions with no TMDB match within a year of the suggested year' do
      stub_claude([
        { title: 'Made Up Movie', year: 2001, reason: 'r' },
        { title: 'Ronin', year: 1998, reason: 'r' }
      ])
      stub_tmdb('Made Up Movie', [tmdb_result(id: 1, title: 'Made Up Movie', year: 2015)])
      stub_tmdb('Ronin', [tmdb_result(id: 8195, title: 'Ronin', year: 1998)])

      results = described_class.get_suggestions(user: user, query: 'heist movies')

      expect(results.movies.map(&:tmdb_id)).to eq([8195])
    end

    it 'drops a suggestion whose TMDB lookup fails and keeps the rest' do
      stub_claude([
        { title: 'Heat', year: 1995, reason: 'r' },
        { title: 'Ronin', year: 1998, reason: 'r' }
      ])
      allow(Tmdb::Client).to receive(:request)
        .with(:movie_search, { query: 'Heat' }, anything)
        .and_raise(OpenURI::HTTPError.new('503', nil))
      stub_tmdb('Ronin', [tmdb_result(id: 8195, title: 'Ronin', year: 1998)])

      results = described_class.get_suggestions(user: user, query: 'heist movies')

      expect(results.movies.map(&:tmdb_id)).to eq([8195])
    end

    it 'drops suggestions whose TMDB lookup is still pending at the deadline' do
      stub_const("#{described_class}::TMDB_LOOKUP_DEADLINE", 0.2)
      stub_claude([
        { title: 'Heat', year: 1995, reason: 'r' },
        { title: 'Ronin', year: 1998, reason: 'r' }
      ])
      allow(Tmdb::Client).to receive(:request).with(:movie_search, { query: 'Heat' }, anything) do
        sleep 1
        { results: [tmdb_result(id: 949, title: 'Heat', year: 1995)] }
      end
      stub_tmdb('Ronin', [tmdb_result(id: 8195, title: 'Ronin', year: 1998)])

      results = described_class.get_suggestions(user: user, query: 'heist movies')

      expect(results.movies.map(&:tmdb_id)).to eq([8195])
    end

    it 'keeps suggestions in the order Claude returned them' do
      titles = %w[Thief Ronin Heat Collateral]
      stub_claude(titles.each_with_index.map { |title, i| { title: title, year: 2000 + i, reason: 'r' } })
      titles.each_with_index do |title, i|
        # Earlier titles respond slower, so lookups finish out of order
        allow(Tmdb::Client).to receive(:request).with(:movie_search, { query: title }, anything) do
          sleep 0.05 * (titles.size - i)
          { results: [tmdb_result(id: 100 + i, title: title, year: 2000 + i)] }
        end
      end

      results = described_class.get_suggestions(user: user, query: 'heist movies')

      expect(results.movies.map(&:tmdb_id)).to eq([100, 101, 102, 103])
    end

    it 'handles screenings with no date watched' do
      undated = create(:screening, user: user)
      undated.update_column(:date_watched, nil)
      stub_claude([])

      expect { described_class.get_suggestions(user: user, query: 'anything') }.not_to raise_error
    end

    it 'prefers an exact title match among same-era results' do
      stub_claude([{ title: 'The Thing', year: 1982, reason: 'r' }])
      stub_tmdb('The Thing', [
        tmdb_result(id: 2, title: 'The Thing Called Love', year: 1982),
        tmdb_result(id: 1091, title: 'The Thing', year: 1982)
      ])

      results = described_class.get_suggestions(user: user, query: 'horror')

      expect(results.movies.map(&:tmdb_id)).to eq([1091])
    end

    it 'drops movies already on the list even if Claude suggests them' do
      stub_claude([{ title: 'Heat', year: 1995, reason: 'r' }])
      stub_tmdb('Heat', [tmdb_result(id: 949, title: 'Heat', year: 1995)])

      results = described_class.get_suggestions(user: user, list: list)

      expect(results.movies).to be_empty
      expect(results.not_found_message).to be_present
    end

    it 'drops movies everyone watched in the last year, but keeps ones only one person watched' do
      seen_by_both = create(:movie, title: 'Collateral', tmdb_id: 1538)
      seen_by_one = create(:movie, title: 'Miami Vice', tmdb_id: 82)
      [user, partner].each { |person| create(:screening, user: person, movie: seen_by_both, date_watched: 2.months.ago) }
      create(:screening, user: partner, movie: seen_by_one, date_watched: 2.months.ago)

      stub_claude([
        { title: 'Collateral', year: 2004, reason: 'r' },
        { title: 'Miami Vice', year: 2006, reason: 'r' }
      ])
      stub_tmdb('Collateral', [tmdb_result(id: 1538, title: 'Collateral', year: 2004)])
      stub_tmdb('Miami Vice', [tmdb_result(id: 82, title: 'Miami Vice', year: 2006)])

      results = described_class.get_suggestions(user: user, list: list)

      expect(results.movies.map(&:tmdb_id)).to eq([82])
      expect(results.movies.first.labels).to eq(["partner watched #{2.months.ago.strftime('%b %Y')}"])
    end

    it "sends movies on a shared Nope list as not interested and never returns them" do
      nope_list = create(:list, owner: partner, name: 'nope')
      create(:membership, list: nope_list, member: user)
      noped = create(:movie, title: 'Blackhat', tmdb_id: 201_088, release_date: '2015-01-16')
      create(:listing, list: nope_list, movie: noped, user: partner)

      stub_claude([{ title: 'Blackhat', year: 2015, reason: 'r' }])
      stub_tmdb('Blackhat', [tmdb_result(id: 201_088, title: 'Blackhat', year: 2015)])

      results = described_class.get_suggestions(user: user, query: 'tech thrillers')

      expect(results.movies).to be_empty
      expect(Claude::Client).to have_received(:request_json) do |prompt:, **|
        expect(prompt).to include("# Not interested\n- Blackhat (2015)")
      end
    end

    it 'labels movies on other lists and sorts them after new ones' do
      other_list = create(:list, owner: user, name: '2 Soon')
      listed = create(:movie, title: 'Manhunter', tmdb_id: 11_454)
      listing = create(:listing, list: other_list, movie: listed, user: user)

      stub_claude([
        { title: 'Manhunter', year: 1986, reason: 'r' },
        { title: 'Thief', year: 1981, reason: 'r' }
      ])
      stub_tmdb('Manhunter', [tmdb_result(id: 11_454, title: 'Manhunter', year: 1986)])
      stub_tmdb('Thief', [tmdb_result(id: 11_524, title: 'Thief', year: 1981)])

      results = described_class.get_suggestions(user: user, list: list)

      expect(results.movies.map(&:tmdb_id)).to eq([11_524, 11_454])
      expect(results.movies.last.labels).to eq(["On 2 Soon since #{listing.created_at.year}"])
    end

    it 'sends the request, list, everyone\'s taste, and exclusions to Claude' do
      favorite = create(:movie, title: 'The Insider', release_date: '1999-11-05')
      create(:rating, user: partner, movie: favorite, value: 10)
      stub_claude([])

      described_class.get_suggestions(user: user, list: list, query: 'but lighter')

      expect(Claude::Client).to have_received(:request_json) do |system:, prompt:, schema:|
        expect(system).to eq(described_class::SYSTEM_PROMPT)
        expect(schema).to eq(described_class::RESPONSE_SCHEMA)
        expect(prompt).to include("# Request\nbut lighter")
        expect(prompt).to include('# List: Esta Noche')
        expect(prompt).to include('# Taste: mike (the person asking)')
        expect(prompt).to include('# Taste: partner')
        expect(prompt).to include('- The Insider (1999) - 10')
        expect(prompt).to include("# Do not suggest\n- Heat (1995)")
      end
    end

    it 'returns a friendly message when Claude fails' do
      allow(Claude::Client).to receive(:request_json).and_raise(Claude::Client::Error, 'boom')

      results = described_class.get_suggestions(user: user, query: 'anything')

      expect(results.movies).to be_empty
      expect(results.not_found_message).to include('Something went wrong')
    end
  end
end
