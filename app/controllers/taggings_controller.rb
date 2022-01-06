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
    @tagging = current_user.taggings.find_by("tag_id = ? AND movie_id = ?", params[:tag_id], params[:movie_id])
    respond_to do |format|
      if @tagging && @tagging.destroy
        format.js {}
      else
        @error = "Unable to delete tag. tag_id: #{params[:tag_id] || 'none'}. movie_id: #{params[:movie_id] || 'none'}"
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
      @movie = Movie.find_by(tmdb_id: params[:tmdb_id]) || tmdb_handler_add_movie(params[:tmdb_id])
    else
      @movie = Movie.friendly.find(params[:movie_id])
    end
  end
end
