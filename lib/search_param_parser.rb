# frozen_string_literal: true

module SearchParamParser
  def self.parse_movie_params(params)
    output = {
      actor: params[:actor],
      actor2: params[:actor2],
      year: nil,
      exact_year: nil,
      year_select: params[:year_select],
      before_year: nil,
      after_year: nil,
      genre: params[:genre],
      company: params[:company],
      mpaa_rating: params[:mpaa_rating],
      page: (params[:page].presence || 1),
      sort_by: (params[:sort_by].presence || 'revenue'),

      actor_display: nil,
      genre_display: nil,
      rating_display: nil,
      year_display: nil,
      sort_display: nil
    }

    output[:actor_display] = "#{params[:actor].titlecase} movies" if params[:actor].present?
    output[:rating_display] = "Rated #{params[:mpaa_rating]}" if params[:mpaa_rating].present?

    year = params[:date][:year] if params[:date].present?
    output[:year] = year
    if year.present? && params[:year_select].present?
      if params[:year_select] == 'exact'
        output[:exact_year] = year
        output[:year_display] = "From #{year}"
      end
      if params[:year_select] == 'before'
        output[:before_year] = "#{year}-01-01"
        output[:year_display] = "Before #{year}"
      end
      if params[:year_select] == 'after'
        output[:after_year] = "#{year}-12-31"
        output[:year_display] = "After #{year}"
      end
    end

    if params[:sort_by].present?
      sort_options = Movie::SORT_BY.to_h
      sort_key = sort_options.key(params[:sort_by])
      output[:sort_display] = "Sorted by #{sort_key}"
    end

    if params[:genre].present?
      genres = Movie::GENRES.to_h
      genre_selected = genres.key(params[:genre].to_i)
      output[:genre_display] = "#{genre_selected} movies"
    end

    output.select { |_k, v| v.present? }
  end
end
