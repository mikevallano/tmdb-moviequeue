class TmdbController < ApplicationController
  before_action :authenticate_user!

  require 'open-uri'
  include TmdbHandler

  def search
    if params[:movie_title]
      @movie_title = params[:movie_title].gsub(' ', '-')
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
    else
      redirect_to movies_path
    end
  end

end