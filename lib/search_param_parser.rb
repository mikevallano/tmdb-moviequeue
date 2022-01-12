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
end
