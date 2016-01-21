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
    @passed_params = [ params[:sort_by], params[:year], params[:genre], params[:actor],
    params[:actor2], params[:company], params[:mpaa_rating], params[:year_select], params[:sort_by] ]
    if @passed_params.any?
      @year_select = params[:year_select]
      if @year_select.present?
        if @year_select == "exact"
          @exact_year = params[:year]
        elsif @year_select == "after"
          @after_year = "#{params[:year]}-01-01"
        elsif @year_select == "before"
          @before_year = "#{params[:year]}-01-01"
        end
      else
        @exact_year = params[:year] if params[:year].present?
        @after_year = nil
        @before_year = nil
      end
      @year = params[:year] if params[:year].present?
      @genre = params[:genre] if params[:genre].present?
      @actor = params[:actor] if params[:actor].present?
      @actor2 = params[:actor2] if params[:actor2].present?
      @company = params[:company] if params[:company].present?
      @mpaa_rating = params[:mpaa_rating] if params[:mpaa_rating].present?
      if params[:sort_by].present?
        @sort_by = params[:sort_by]
      else
        @sort_by = "revenue"
      end
      if params[:page]
        @page = params[:page]
      else
        @page = 1
      end
    tmdb_handler_discover_search(@exact_year, @after_year, @before_year, @genre, @actor, @actor2,
      @company, @mpaa_rating, @sort_by, @page)
    end
  end

end