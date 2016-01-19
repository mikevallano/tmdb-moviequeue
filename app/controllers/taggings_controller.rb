class TaggingsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_url

  def create
    @tag_names = params[:tag_list]
    @movie_id = params[:movie_id]

    @movie = Movie.friendly.find(@movie_id)

    Tagging.create_taggings(@tag_names, @movie_id, current_user)

    respond_to do |format|
      format.js {}
      format.html { redirect_to @redirect_url, notice: 'Tag was added.' }
    end
  end

  def destroy
    @from = params[:from] #account for page number too
    @tagging = current_user.taggings.find_by("tag_id = ? AND movie_id = ?", params[:tag_id], params[:movie_id])
    @movie_id = params[:movie_id]
    @movie = Movie.friendly.find(@movie_id)
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
    params.require(:tagging).permit(:tag_id, :tag_list, :movie_id, :user_id)
  end

  def redirect_url
    @page = params[:page] if params[:page].present?
    if params[:list_id].present?
      @list = current_user.lists.find(params[:list_id])
      @redirect_url = user_list_path(current_user, @list, page: @page)
    elsif params[:from].present? && params[:from] == "movie"
      @movie = current_user.movies.find(params[:movie_id])
      @redirect_url = movie_path(@movie)
    else
      @redirect_url = movies_path(page: @page)
    end
  end

end