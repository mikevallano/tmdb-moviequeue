class TmdbController < ApplicationController
  before_action :authenticate_user!

  require 'open-uri'
  include TmdbHandler
  include SearchParamParser

  def search
    if @movie_title = params[:movie_title] || params[:movie_title_header]
      @search_results = tmdb_handler_search(@movie_title)
    end
  end

  def two_movie_search
    if params[:movie_one] && params[:movie_two]
      @search_results = tmdb_handler_two_movie_search(params[:movie_one], params[:movie_two])
    end
  end

  def movie_autocomplete
    tmdb_handler_movie_autocomplete(params[:term])
    render json: @autocomplete_results
  end

  def person_autocomplete
    tmdb_handler_person_autocomplete(params[:term])
    render json: @autocomplete_results
  end

  def movie_more
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      tmdb_handler_movie_more(@tmdb_id)
    else
      redirect_to api_search_path
    end
  end

  def update_tmdb_data
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      movie = Movie.find_by!(tmdb_id: @tmdb_id)
      TmdbHandler.tmdb_handler_update_movie(movie)
    end
    redirect_to movie_more_path(tmdb_id: @tmdb_id)
  end

  def similar_movies
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      if params[:page]
        @page = params[:page]
      else
        @page = 1
      end #if page
      tmdb_handler_similar_movies(@tmdb_id, @page)
    end #if tmdb_id
  end #similar movies

  def full_cast
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      tmdb_handler_full_cast(@tmdb_id)
    end
  end #full cast

  def actor_search
    if params[:actor]
      params[:actor] = I18n.transliterate(params[:actor])
      params[:page] = params[:page] || 1
      params[:sort_by] = params[:sort_by] || "popularity"

      tmdb_handler_discover_search(params)
    end
  end

  def two_actor_search
    if params[:actor] && params[:actor2]
      params[:actor] = I18n.transliterate(params[:actor])
      params[:actor2] = I18n.transliterate(params[:actor2])
      params[:page] = params[:page] || 1
      params[:sort_by] = params[:sort_by] || "popularity"

      tmdb_handler_discover_search(params)
    end
  end

  def actor_more
    @actor = tmdb_handler_person_detail_search(params[:actor_id])
  end

  def actor_credit
    credit_id = params[:credit_id]
    @credit = tmdb_handler_actor_credit(credit_id)
  end

  def tv_series_search
    query = show_title = params[:show_title] || params[:show_title_header]
    if query.present?
      @query = I18n.transliterate(query)
      @search_results = tmdb_handler_tv_series_search(query)
    end
  end

  def tv_series_autocomplete
    autocomplete_results = tmdb_handler_tv_series_autocomplete(params[:term])
    render json: autocomplete_results
  end

  def tv_series
    show_id = params[:show_id]
    @series = tmdb_handler_tv_series(show_id)
  end

  def tv_season
    show_id = params[:show_id]
    season_number = params[:season_number]
    @series = tmdb_handler_tv_series(show_id)
    @season = tmdb_handler_tv_season(
      series: @series,
      show_id: show_id,
      season_number: season_number
    )
  end

  def tv_episode
    show_id = params[:show_id]
    season_number = params[:season_number]
    @series = tmdb_handler_tv_series(show_id)
    @season = tmdb_handler_tv_season(
      series: @series,
      show_id: show_id,
      season_number: season_number
    )
    @episode = tmdb_handler_tv_episode(
      show_id: show_id,
      season_number: season_number,
      episode_number: params[:episode_number]
    )
  end

  def director_search
    if params[:director_id]
      @director = tmdb_handler_person_detail_search(params[:director_id])
    end
  end

  def discover_search
    #format date/year hash passed in params. otherwise year is passed directly on paginated pages
    params[:year] = params[:date][:year] if params[:date].present?

    @passed_params = params.slice(:sort_by, :year, :genre, :actor, :actor2,
      :company, :mpaa_rating, :year_select, :page).select{ |k, v| v.present?}

    if @passed_params.any?
      parse_params(@passed_params) #module to help parse

      #parse passed params to show user what they searched for
      @discover_view_params = @passed_params.slice(:actor, :genre, :date, :year, :year_select, :mpaa_rating, :sort_by)
      @params_for_view = discover_show_search_params(@discover_view_params)

      tmdb_handler_discover_search(@passed_params)
    end

  end #discover search

  def discover_show_search_params(show_params)
    @keys = show_params.keys
    @actor_display = show_params[:actor].titlecase if @keys.include?("actor")

    if @keys.include?("genre")
      @genre_id = show_params[:genre].to_i
      @genres = Movie::GENRES.to_h
      @genre_selected = @genres.key(@genre_id)
      @genre_display = "#{@genre_selected} movies"
    end

    @rating_display = "Rating: #{show_params[:mpaa_rating]}" if @keys.include?("mpaa_rating")

    if show_params[:year_select] == "exact" || !show_params[:year_select].present?
      @year_select_display = "From"
    else
      @year_select_display = show_params[:year_select]
    end

    @year_show = show_params[:year] if @keys.include?("year")
    @year_display = "#{@year_select_display} #{@year_show}" if @year_show.present?

    if @keys.include?("sort_by")
      @sort_selected = show_params[:sort_by]
      @sort_options = Movie::SORT_BY.to_h
      @sort_key = @sort_options.key(@sort_selected)
      @sort_display = "sorted by #{@sort_key}" if @keys.include?("sort_by")
    end
    "#{@actor_display} #{@genre_display} #{@rating_display} #{@year_display} #{@sort_display}"
  end

end #final
