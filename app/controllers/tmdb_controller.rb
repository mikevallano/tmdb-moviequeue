# frozen_string_literal: true

class TmdbController < ApplicationController
  require 'open-uri'
  before_action :authenticate_user!

  def search
    if @movie_title = params[:movie_title] || params[:movie_title_header]
      @search_results = Tmdb::Client.get_movie_search_results(@movie_title)
    end
  end

  # common actors between 2 movies
  def two_movie_search
    if params[:movie_one] && params[:movie_two]
      @search_results = Tmdb::Client.get_common_actors_between_movies(params[:movie_one], params[:movie_two])
    end
  end

  def movie_autocomplete
    results = Tmdb::Client.get_movie_titles(params[:term])
    render json: results
  end

  def person_autocomplete
    results = Tmdb::Client.get_person_names(params[:term])
    render json: results
  end

  def movie_more
    if params[:tmdb_id]
      @movie = GuaranteedMovie.find_or_initialize_from_api(params[:tmdb_id])
    else
      redirect_to api_search_path
    end
  end

  def update_tmdb_data
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      movie = Movie.find_by!(tmdb_id: @tmdb_id)
      Tmdb::Client.update_movie(movie)
    end
    redirect_to movie_more_path(tmdb_id: @tmdb_id)
  end

  def full_cast
    if params[:tmdb_id]
      @cast = Tmdb::Client.get_movie_cast(params[:tmdb_id])
    end
  end

  # movies for single actor
  def actor_search
    if params[:actor].present?
      @results = Tmdb::Client.get_movies_for_actor(
        actor_name: params[:actor],
        page: params[:page],
        sort_by: params[:sort_by]
      )
    end
  end

  # common movies between 2 actors
  def two_actor_search
    if (params[:actor] && params[:actor2]) || params[:paginate_actor_names].present?
      @results = Tmdb::Client.get_common_movies_between_multiple_actors(
        actor_names: [
          params[:actor],
          params[:actor2]
        ],
        paginate_actor_names: params[:paginate_actor_names],
        page: params[:page],
        sort_by: params[:sort_by]
      )
    end
  end

  def actor_more
    @actor = Tmdb::Client.get_person_profile_data(params[:actor_id])
  end

  def actor_credit
    credit_id = params[:credit_id]
    @credit = Tmdb::Client.get_actor_tv_appearance_credits(credit_id)
  end

  def tv_series_search
    query = show_title = params[:show_title] || params[:show_title_header]
    if query.present?
      @query = I18n.transliterate(query)
      @search_results = Tmdb::Client.get_tv_series_search_results(query)
    end
  end

  def tv_series_autocomplete
    autocomplete_results = Tmdb::Client.get_tv_series_names(params[:term])
    render json: autocomplete_results
  end

  def tv_series
    show_id = params[:show_id]
    @series = Tmdb::Client.get_tv_series_data(show_id)
  end

  def tv_season
    @series = Tmdb::Client.get_tv_series_data(params[:show_id])
    @season = Tmdb::Client.get_tv_season_data(
      series: @series,
      season_number: params[:season_number]
    )
  end

  def tv_episode
    series_id = params[:show_id]
    season_number = params[:season_number]
    @series = Tmdb::Client.get_tv_series_data(series_id)
    @season = Tmdb::Client.get_tv_season_data(
      series: @series,
      season_number: season_number
    )
    @episode = Tmdb::Client.get_tv_episode_data(
      series_id: series_id,
      season_number: season_number,
      episode_number: params[:episode_number]
    )
  end

  def director_search
    if params[:director_id]
      @director = Tmdb::Client.get_person_profile_data(params[:director_id])
    end
  end

  def discover_search
    form_params = %i[sort_by date genre actor_name company mpaa_rating timeframe page]
    passed_params = params.slice(*form_params).select { |_k, v| v.present? }
    return if passed_params.blank?

    searchable_params = SearchParamParser.parse_movie_params(passed_params)
    @data = Tmdb::Client.get_advanced_movie_search_results(searchable_params)
    @params_for_view = SearchParamParser.parse_movie_params_for_display(passed_params)
  end
end
