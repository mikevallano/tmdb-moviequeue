class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params["tag"]
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list)
      else
        @movies = current_user.movies.tagged_with(params["tag"], current_user)
      end
    else
      @movies = current_user.all_movies
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end


end
