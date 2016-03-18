class MoviesController < ApplicationController
  before_action :authenticate_user!
  include SortingHandler
  include TmdbHandler

  def index
    if params["tag"]
      @tag = Tag.find_by(name: params["tag"])
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list).paginate(:page => params[:page], per_page: 20)
      else #params list_id
        @movies = Movie.by_tag_and_user(@tag, current_user).paginate(:page => params[:page], per_page: 20)
      end #if params list_id
    elsif params[:genre]
      @genre = params[:genre]
      @movies = current_user.movies_by_genre(@genre).paginate(:page => params[:page], per_page: 20)
    else
      @movies = current_user.all_movies.paginate(:page => params[:page], per_page: 20)
    end #if params tag


    @sort_by = params[:sort_by]
    if @sort_by.present?
      movies_index_sort_handler(@sort_by)
    end #if @sort_by.present?

  end #index

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end

  end #show

  def modal
    @list = List.find(params[:list_id]) if params[:list_id].present?
    @tmdb_id = params[:tmdb_id]
    if Movie.exists?(tmdb_id: @tmdb_id)
      @movie = Movie.find_by(tmdb_id: @tmdb_id)
    else
      tmdb_handler_movie_more(@tmdb_id)
    end
    respond_to :js
  end

  def modal_close
    @tmdb_id = params[:tmdb_id]
    if Movie.exists?(tmdb_id: @tmdb_id)
      @movie = Movie.find_by(tmdb_id: @tmdb_id)
    else
      tmdb_handler_movie_more(@tmdb_id)
    end
    respond_to :js
  end

end
