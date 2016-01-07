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
    if params[:movie_id]
      @movie_id = params[:movie_id]
      tmdb_handler_movie_info(@movie_id)
    else
      redirect_to api_search_path
    end
  end

  def actor_search
    if params[:name]
      @name = params[:name]
      if params[:page]
        @page = params[:page]
      else
        @page = 1
      end
      tmdb_handler_actor_search(@name, @page)
    end
  end

  def actor_more
    @actor_id = params[:actor_id]
    tmdb_handler_actor_more(@actor_id)
  end

  def actor_credit
    @credit_id = params[:credit_id]
    @actor_id = params[:actor_id]
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

  def two_actor_search
    if params[:name_one] && params[:name_two]
      @name_one = params[:name_one]
      @name_two = params[:name_two]
      tmdb_handler_two_actor_search(@name_one, @name_two)
    end
  end

  def director_search
    if params[:director_id]
      @director_id = params[:director_id]
      @name = params[:name]
      tmdb_handler_director_search(@director_id)
    end
  end

end