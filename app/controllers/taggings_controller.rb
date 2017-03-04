class TaggingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie

  include TmdbHandler

  def create
    @tag_names = params[:tag_list]
    @list = List.find(params[:list_id]) if params[:list_id].present?

    Tagging.create_taggings(@tag_names, @movie.id, current_user)

    respond_to do |format|
      format.js {}
      format.html { redirect_to movie_path(@movie), notice: 'Tag was added.' }
    end
  end

  def destroy
    @list = List.find(params[:list_id]) if params[:list_id].present?
    @tagging = current_user.taggings.find_by("tag_id = ? AND movie_id = ?", params[:tag_id], params[:movie_id])
    respond_to do |format|
      if @tagging && @tagging.destroy
        format.js {}
      else
        @error = 'Unable to delete tag'
        format.js {}
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

end
