# frozen_string_literal: true

require 'rails_helper'

describe SearchParamParser do
  describe 'self.parse_movie_params' do
    context 'page' do
      context 'when page is present' do
        it 'sets the page value to the params value' do
          result = described_class.parse_movie_params(page: 5)
          expect(result[:page]).to eq(5)
        end
      end

      context 'when page is not present' do
        it 'defaults to 1' do
          result = described_class.parse_movie_params(page: '')
          expect(result[:page]).to eq(1)
        end
      end
    end

    context 'sort_by' do
      context 'when sort_by is present' do
        it 'sets the sort_by value to the params value' do
          result = described_class.parse_movie_params(sort_by: 'foo')
          expect(result[:sort_by]).to eq('foo')
        end
      end

      context 'when sort_by is not present' do
        it 'defaults to "popularity"' do
          result = described_class.parse_movie_params(sort_by: '')
          expect(result[:sort_by]).to eq('popularity')
        end
      end
    end
  end

  describe 'self.parse_movie_params_for_display' do
    context 'actor_display' do
      context 'when an actor is present' do
        it 'sets the actor_display to a title-cased actor name' do
          result = described_class.parse_movie_params_for_display(actor_name: 'foo bar')
          expect(result).to eq('Foo Bar movies')
        end
      end

      context 'when an actor not is present' do
        it 'does not include the actor_display key' do
          result = described_class.parse_movie_params_for_display(actor_name: '')
          expect(result).to eq('')
        end
      end
    end

    context 'genre_display' do
      before { stub_const('Movie::GENRES', GENRES = [['Cat', 42]].freeze) }
      context 'when genre is present' do
        it 'sets the genre_display to a genre name' do
          result = described_class.parse_movie_params_for_display(genre: 42)
          expect(result).to eq('Cat movies')
        end
      end

      context 'when genre not is present' do
        it 'does not include the genre_display key' do
          result = described_class.parse_movie_params_for_display(actor_name: '')
          expect(result).to eq('')
        end
      end
    end

    context 'rating_display' do
      context 'when mpaa_rating is present' do
        it 'sets the rating_display' do
          result = described_class.parse_movie_params_for_display(mpaa_rating: 'R')
          expect(result).to eq('Rated R')
        end
      end

      context 'when mpaa_rating not is present' do
        it 'does not include the rating_display key' do
          result = described_class.parse_movie_params_for_display(mpaa_rating: '')
          expect(result).to eq('')
        end
      end
    end

    context 'sort_display' do
      before { stub_const('Movie::SORT_BY', SORT_BY = [['Fancy Foo', 'foo']].freeze) }
      context 'when sort_by is present' do
        it 'sets the sort_display to a sorting option name' do
          result = described_class.parse_movie_params_for_display(sort_by: 'foo')
          expect(result).to eq('sorted by Fancy Foo')
        end
      end

      context 'when sort_by not is present' do
        it 'does not include the sort_display key' do
          result = described_class.parse_movie_params_for_display(sort_by: '')
          expect(result).to eq('')
        end
      end

      context 'when multiple params are present' do
        let(:year) { '2020' }
        let(:date) { { year: year } }
        it 'joins them all in one pretty string' do
          result = described_class.parse_movie_params_for_display(
            actor_name: 'jazzy jeff',
            mpaa_rating: 'R',
            date: date
          )
          expect(result).to eq('Jazzy Jeff movies, Rated R, from 2020')
        end
      end
    end

    context 'years' do
      let(:year) { '2020' }
      let(:date) { { year: year } }

      context 'year is present' do
        context 'when timeframe is not present' do
          it 'defaults to "exact"' do
            result = described_class.parse_movie_params_for_display(
              timeframe: '',
              date: date
            )
            expect(result).to eq('from 2020')
          end
        end

        context 'when timeframe is "exact"' do
          it 'says "From" the year' do
            result = described_class.parse_movie_params_for_display(
              timeframe: 'exact',
              date: date
            )
            expect(result).to eq('from 2020')
          end
        end

        context 'when timeframe is "before"' do
          it 'says "Before" the year' do
            result = described_class.parse_movie_params_for_display(
              timeframe: 'before',
              date: date
            )
            expect(result).to eq('before 2020')
          end
        end

        context 'when timeframe is "after"' do
          it 'says "After" the year' do
            result = described_class.parse_movie_params_for_display(
              timeframe: 'after',
              date: date
            )
            expect(result).to eq('after 2020')
          end
        end
      end

      context 'when year is not present' do
        it 'does not set any of the year keys' do
          result = described_class.parse_movie_params_for_display(
            timeframe: '',
            date: ''
          )
          expect(result).to eq('')
        end
      end
    end
  end
end
