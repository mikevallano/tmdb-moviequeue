class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 20
    if params["tag"]
      @tag = Tag.find_by(name: params["tag"])
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list).paginate(:page => params[:page], :per_page => @per_page)
      else #params list_id
        @movies = Movie.by_tag_and_user(@tag, current_user).paginate(:page => params[:page], :per_page => @per_page)
      end #params list_id
    else #params tag
      @movies = current_user.all_movies.paginate(:page => params[:page], :per_page => @per_page)
    end #params tag
    if params[:genre]
      @movies = current_user.movies.by_genre(params[:genre]).paginate(:page => params[:page], :per_page => @per_page)
    end #params genre

    @sort_by = params[:sort_by]
    if @sort_by.present?
      case @sort_by
      when "title"
        @movies = current_user.all_movies_by_title.paginate(:page => params[:page], per_page: 20)
      when "shortest runtime"
        @movies = current_user.all_movies_by_shortest_runtime.paginate(:page => params[:page], per_page: 20)
      when "longest runtime"
        @movies = current_user.all_movies_by_longest_runtime.paginate(:page => params[:page], per_page: 20)
      when "newest release"
        @movies = current_user.all_movies_by_recent_release_date.paginate(:page => params[:page], per_page: 20)
      when "vote average"
        @movies = current_user.all_movies_by_highest_vote_average.paginate(:page => params[:page], per_page: 20)
      when "recently watched"
        @movies = current_user.all_movies_by_recently_watched.paginate(:page => params[:page], per_page: 20)
      when "watched movies"
        @movies = current_user.all_movies_by_watched.paginate(:page => params[:page], per_page: 20)
      when "unwatched movies"
        @movies = @movies = current_user.all_movies_by_unwatched.paginate(:page => params[:page], per_page: 20)
      when "only show unwatched"
        @movies = Movie.unwatched_by_user(current_user).paginate(:page => params[:page], per_page: 20)
      when "only show watched"
        @movies = current_user.watched_movies.paginate(:page => params[:page], per_page: 20)
      when "movies not on a list"
        @movies = current_user.all_movies_not_on_a_list.paginate(:page => params[:page], per_page: 20)
      else
        @movies = current_user.all_movies.paginate(:page => params[:page], :per_page => @per_page)
      end #case
    end #if @sort_by.present?

  end #index

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end

  end #show

end
