# frozen_string_literal: true

module SearchParamParser
  def self.parse_movie_params(params)
    output = {
      actor: params[:actor],
      actor2: params[:actor2],
      year: nil,
      year_select: nil,
      genre: params[:genre],
      company: params[:company],
      mpaa_rating: params[:mpaa_rating],
      page: (params[:page].presence || 1),
      sort_by: (params[:sort_by].presence || 'revenue')
    }

    year_from_date = params[:date][:year] if params[:date].present?
    output[:year] = year_from_date.presence || params[:year]
    output[:year_select] = (params[:year_select].presence || 'exact') if output[:year].present?
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

    year_from_date = params[:date][:year] if params[:date].present?
    year = year_from_date.presence || params[:year]
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
