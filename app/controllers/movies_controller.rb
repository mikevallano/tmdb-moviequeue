# frozen_string_literal: true

class MoviesController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_admin!, only: :update
  before_action :set_movie, only: [:update]
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
      @movies = current_user.all_movies_by_recently_watched.paginate(:page => params[:page], per_page: 20)
    end #if params tag

    @sort_by = params[:sort_by]
    if @sort_by.present?
      movies_index_sort_handler(@sort_by)
    end #if @sort_by.present?
  end

  def update
    if @movie.update(required_params)
      redirect_to movie_path(@movie, anchor: 'trailer-section')
    else
      redirect_to movie_path(@movie), notice: @movie.errors.full_messages
    end
  end

  def show
    @movie = Movie.friendly.find(params[:id])
    if request.path != movie_path(@movie)
      return redirect_to @movie, :status => :moved_permanently
    end
  end

  def modal
    @list = List.find(params[:list_id]) if params[:list_id].present?
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id]) || Tmdb::Client.get_movie_data(params[:tmdb_id])
    respond_to :js
  end

  def modal_close
    @movie = Movie.find_by(tmdb_id: params[:tmdb_id]) || Tmdb::Client.get_movie_data(params[:tmdb_id])
    respond_to :js
  end

  private

  def set_movie
    if params[:tmdb_id].present?
      @movie = GuaranteedMovie.find(params[:tmdb_id])
    else
      @movie = Movie.friendly.find(params[:movie_id])
    end
  end

  def required_params
    trailer_url = params[:trailer]
    params[:trailer] = trailer_url.include?('youtube.com') ? youtube_id : trailer_url
    params.permit(:trailer)
  end

  def youtube_id
    uri = URI.parse(params[:trailer])
    CGI::parse(uri.query)['v']&.first if uri.query
  end
end
