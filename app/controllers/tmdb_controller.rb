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

  def more
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
      tmdb_handler_actor_search(@name)
    end
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