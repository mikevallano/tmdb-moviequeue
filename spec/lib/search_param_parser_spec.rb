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
        it 'defaults to "revenue"' do
          result = described_class.parse_movie_params(sort_by: '')
          expect(result[:sort_by]).to eq('revenue')
        end
      end
    end

    context 'years' do
      let(:year) { '2020' }
      let(:date) { { year: year } }

      context 'year is present' do
        context 'handling date vs year' do
          it 'works with date and no year' do
            result = described_class.parse_movie_params(
              year_select: '',
              date: date,
              year: ''
            )
            expect(result[:year]).to eq(year)
          end

          it 'works with year and no date' do
            result = described_class.parse_movie_params(
              year_select: '',
              date: '',
              year: year
            )
            expect(result[:year]).to eq(year)
          end
        end

        context 'when year_select is not present' do
          it 'defaults to "exact"' do
            result = described_class.parse_movie_params(
              year_select: '',
              date: date
            )
            expect(result[:year_select]).to eq('exact')
          end
        end

        context 'when year_select is "exact"' do
          let(:year_select) { 'exact' }
          it 'sets the exact_year value' do
            result = described_class.parse_movie_params(
              year_select: year_select,
              date: date
            )
            expect(result[:year_select]).to eq(year_select)
          end
        end

        context 'when year_select is "before"' do
          let(:year_select) { 'before' }
          it 'sets the year_select value to "before"' do
            result = described_class.parse_movie_params(
              year_select: year_select,
              date: date
            )
            expect(result[:year_select]).to eq(year_select)
          end
        end

        context 'when year_select is "after"' do
          let(:year_select) { 'after' }
          it 'sets the year_select value to "after"' do
            result = described_class.parse_movie_params(
              year_select: year_select,
              date: date
            )
            expect(result[:year_select]).to eq(year_select)
          end
        end
      end

      context 'when year is not present' do
        let(:year_select) { 'before' }
        it 'does not set any of the year keys' do
          result = described_class.parse_movie_params(
            year_select: year_select,
            date: '',
            year: ''
          )
          expect(result[:year_select]).to be(nil)
          expect(result[:year]).to be(nil)
        end
      end
    end
  end
end
