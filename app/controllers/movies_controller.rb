class MoviesController < ApplicationController
  before_action :authenticate_user!

  def index
    @per_page = 20
    if params["tag"]
      @tag = params["tag"]
      if params[:list_id]
        @list = List.find(params[:list_id])
        @movies = @list.movies.tagged_with(params['tag'], @list).paginate(:page => params[:page], :per_page => @per_page)
      else
        @movies = current_user.movies.tagged_with(params["tag"], current_user).paginate(:page => params[:page], :per_page => @per_page)
      end
    else #params tag
      @movies = current_user.all_movies.paginate(:page => params[:page], :per_page => @per_page)
    end #params tag
    if params[:genre]
      @movies = current_user.movies.by_genre(params[:genre]).paginate(:page => params[:page], :per_page => @per_page)
    end
  end

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end

    #consistent variables to share partials between movie_show and api_more_info
    @title = @movie.title
    @tmdb_id = @movie.tmdb_id
    @release_date = @movie.release_date
    @vote_average = @movie.vote_average
    @genres = @movie.genres
    @overview = @movie.overview
    @actors = @movie.actors
    @youtube_trailers = @movie.trailer
    @backdrop_path = @movie.backdrop_path
    @poster_path = @movie.poster_path
    @youtube_trailers = @movie.trailer
    @trailer_url = @movie.trailer
    @mpaa_rating = @movie.mpaa_rating
    @director = @movie.director
    @director_id = @movie.director_id

  end #show

end
