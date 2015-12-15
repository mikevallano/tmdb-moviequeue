class TaggingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @tag_names = params[:tag_list]
    @movie_id = params[:movie_id]

    Tagging.create_taggings(@tag_names, @movie_id, current_user)

    respond_to do |format|
        format.html { redirect_to movies_path, notice: 'Tag was added.' }
    end
  end

  def destroy
    @tagging = current_user.taggings.find_by("tag_id = ? AND movie_id = ?", params[:tag_id], params[:movie_id])
    @tagging.destroy
    respond_to do |format|
      format.html { redirect_to movie_path(@tagging.movie_id), notice: 'Tag was removed.' }
      format.json { head :no_content }
    end
  end

private

  def tagging_params
    params.require(:tagging).permit(:tag_id, :tag_list, :movie_id, :user_id)
  end

end