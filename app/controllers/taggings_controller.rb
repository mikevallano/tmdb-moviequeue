class TaggingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:create, :destroy]

  def create
    @list = List.find(params[:list_id]) if params[:list_id].present?
    Tagging.create_taggings(params[:tag_list], @movie.id, current_user)

    respond_to do |format|
      format.turbo_stream {}
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
      @movie = GuaranteedMovie.find_or_create(params[:tmdb_id])
    else
      @movie = Movie.friendly.find(params[:movie_id])
    end
  end
end
