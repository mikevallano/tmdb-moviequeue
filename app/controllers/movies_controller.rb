class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params["tag"]
      @movies = Movie.includes(:tags, :taggings).by_user(current_user).tagged_with(params["tag"], current_user)
    else
      @movies = Movie.includes(:taggings).by_user(current_user)
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end


end
