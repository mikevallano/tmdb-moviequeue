class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    if params["tag"]
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list).paginate(:page => params[:page], :per_page => 1)
      else
        @movies = current_user.movies.tagged_with(params["tag"], current_user).paginate(:page => params[:page], :per_page => 1)
      end
    else
      @movies = current_user.all_movies.paginate(:page => params[:page], :per_page => 1)
    end
    if params[:genre]
      @movies = current_user.movies.by_genre(params[:genre]).paginate(:page => params[:page], :per_page => 1)
    end
  end

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end
  end


end
