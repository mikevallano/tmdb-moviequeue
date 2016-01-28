class TmdbController < ApplicationController
  before_action :authenticate_user!

  require 'open-uri'
  include TmdbHandler

  def search
    if params[:movie_title]
      @movie_title = params[:movie_title]
      tmdb_handler_search(@movie_title)
    end
  end

  def movie_more
    if params[:tmdb_id]
      @tmdb_id = params[:tmdb_id]
      tmdb_handler_movie_more(@tmdb_id)
    else
      redirect_to api_search_path
    end
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
      @actor = params[:actor]
      if params[:page]
        @page = params[:page]
      else
        @page = 1
      end
      if params[:sort_by].present?
        @sort_by = params[:sort_by]
      else
        @sort_by = "popularity"
      end
      tmdb_handler_discover_search(nil, nil, nil, nil, @actor, nil, nil, nil, @sort_by, @page)
    end
  end

  def two_actor_search
    if params[:actor] && params[:actor2]
      @actor = params[:actor]
      @actor2 = params[:actor2]
      if params[:page]
        @page = params[:page]
      else
        @page = 1
      end
      if params[:sort_by].present?
        @sort_by = params[:sort_by]
      else
        @sort_by = "popularity"
      end
      # tmdb_handler_two_actor_search(@name_one, @name_two)
      tmdb_handler_discover_search(nil, nil, nil, nil, @actor, @actor2, nil, nil, @sort_by, @page)
    end
  end

  def actor_more
    @actor_id = params[:actor_id]
    tmdb_handler_actor_more(@actor_id)
  end

  def actor_credit
    @credit_id = params[:credit_id]
    @actor_id = params[:actor_id]
    @show_name = params[:show_name]
    tmdb_handler_actor_credit(@credit_id)
  end

  def tv_more
    @show_id = params[:show_id]
    @actor_id = params[:actor_id]
    tmdb_handler_tv_more(@show_id)
  end

  def tv_season
    @season_number = params[:season_number]
    @show_id = params[:show_id]
    @show_name = params[:show_name]
    @actor_id = params[:actor_id]
    tmdb_handler_tv_season(@show_id, @season_number)
  end

  def two_movie_search
    if params[:movie_one] && params[:movie_two]
      @movie_one = params[:movie_one]
      @movie_two = params[:movie_two]
      tmdb_handler_two_movie_search(@movie_one, @movie_two)
    end
  end

  def director_search
    if params[:director_id]
      @director_id = params[:director_id]
      @name = params[:name]
      tmdb_handler_director_search(@director_id)
    end
  end

  def discover_search
    if params[:date].present?
      unless params[:date][:year].present?
        params[:date] = ""
      end
    end

    #cleaned_params prohibits users from passing unwanted params
    @cleaned_params = params.slice(:sort_by, :date, :genre, :actor, :actor2, :company, :mpaa_rating, :year_select)

    @passed_params = @cleaned_params.select{ |k, v| v.present?}

    #to show users what they searched for. needs to be redone. this is just temporary
    @params_for_view = @passed_params.values.join(', ')

    if @passed_params.any?
      # use the MovieDiscover class to parse the params
      @search_query = MovieDiscover.parse_params(@cleaned_params)

      #use the instance of MovieDiscover class to pass the data to the tmdb_handler
      tmdb_handler_discover_search(@search_query.exact_year, @search_query.after_year, @search_query.before_year,
        @search_query.genre, @search_query.actor, @search_query.actor2, @search_query.company, @search_query.mpaa_rating,
        @search_query.sort_by, @search_query.page)
    end

  end #discover search

end #final