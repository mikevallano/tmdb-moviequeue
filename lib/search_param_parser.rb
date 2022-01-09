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
      sort_by: (params[:sort_by].presence || 'revenue')
    }

    year = params[:date][:year] if params[:date].present?
    output[:year] = year
    if year.present?
      output[:exact_year] = year if params[:year_select].blank? || params[:year_select] == 'exact'
      output[:before_year] = "#{year}-01-01" if params[:year_select] == 'before'
      output[:after_year] = "#{year}-12-31" if params[:year_select] == 'after'
    end
    output.select { |_k, v| v.present? }
  end

  def self.parse_movie_params_for_display(params)
    output = {}
    output[:actor_display] = "#{params[:actor].titlecase} movies" if params[:actor].present?
    output[:rating_display] = "Rated #{params[:mpaa_rating]}" if params[:mpaa_rating].present?

    if params[:genre].present?
      genres = Movie::GENRES.to_h
      genre_selected = genres.key(params[:genre].to_i)
      output[:genre_display] = "#{genre_selected} movies"
    end

    year = params[:date][:year] if params[:date].present?
    if year.present?
      output[:year_display] =
        case params[:year_select]
        when 'before' then "before #{year}"
        when 'after' then "after #{year}"
        else "from #{year}"
        end
    end

    if params[:sort_by].present?
      sort_options = Movie::SORT_BY.to_h
      sort_key = sort_options.key(params[:sort_by])
      output[:sort_display] = "sorted by #{sort_key}"
    end

    output
      .select { |_k, v| v.present? }
      .values
      .join(', ')
  end
end
