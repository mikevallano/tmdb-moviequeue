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

  end

end