class MoviesController < ApplicationController
  include SortingHandler
  before_action :authenticate_user!

  def index
    if params["tag"]
      @tag = Tag.find_by(name: params["tag"])
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list).paginate(:page => params[:page], per_page: 20)
      else #params list_id
        @movies = Movie.by_tag_and_user(@tag, current_user).paginate(:page => params[:page], per_page: 20)
      end #params list_id
    else #params tag
      @movies = current_user.all_movies.paginate(:page => params[:page], per_page: 20)
    end #params tag

    if params[:genre]
      @movies = current_user.movies.by_genre(params[:genre])
    end #params genre

    @sort_by = params[:sort_by]
    if @sort_by.present?
      movies_index_sort_handler(@sort_by)
    else
      @movies = current_user.all_movies.paginate(:page => params[:page], per_page: 20)
    end #if @sort_by.present?

    # @movies = @movies.paginate(:page => params[:page], per_page: 20)

  end #index

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end

  end #show

end
