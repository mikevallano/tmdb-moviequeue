class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    @movies = current_user.movies
  end

  def show
    @movie = Movie.find(params[:id])
  end


end
