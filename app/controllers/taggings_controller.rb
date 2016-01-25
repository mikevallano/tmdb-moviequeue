class TaggingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie
  before_action :redirect_url

  include TmdbHandler

  def create
    @tag_names = params[:tag_list]

    Tagging.create_taggings(@tag_names, @movie.id, current_user)

    respond_to do |format|
      format.js {}
      format.html { redirect_to @redirect_url, notice: 'Tag was added.' }
    end
  end

  def destroy
    @from = params[:from] #account for page number too
    @tagging = current_user.taggings.find_by("tag_id = ? AND movie_id = ?", params[:tag_id], params[:movie_id])
    respond_to do |format|
      if @tagging.destroy
        format.js {}
        format.html { redirect_to @redirect_url, notice: 'Tag was removed.' }
        format.json { head :no_content }
      else
        redirect_to @redirect_url, notice: "tag not removed"
      end
    end
  end

private

  def tagging_params
    params.require(:tagging).permit(:tag_id, :tag_list, :movie_id, :user_id, :tmdb_id)
  end

  def set_movie
    if params[:tmdb_id].present?
      @tmdb_id = params[:tmdb_id]
      unless Movie.exists?(tmdb_id: @tmdb_id)
        tmdb_handler_add_movie(@tmdb_id)
      end
        @movie = Movie.find_by(tmdb_id: @tmdb_id)
      else
        @movie = Movie.friendly.find(params[:movie_id])
    end
  end #set movie

  def redirect_url
    :set_movie
    @page = params[:page] if params[:page].present?
    if params[:list_id].present?
      @list = current_user.all_lists.find(params[:list_id])
      @redirect_url = user_list_path(current_user, @list, page: @page)
    elsif params[:from].present? && params[:from] == "movie"
      @redirect_url = movie_path(@movie)
    else
      @redirect_url = movies_path(page: @page)
    end
  end

end