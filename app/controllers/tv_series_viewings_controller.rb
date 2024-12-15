class TVSeriesViewingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tv_series_viewing, only: [:edit, :update, :destroy]

  def index
    @tv_series_viewings = current_user.tv_series_viewings
  end

  def edit
  end

  def create
    @tv_series_viewing = current_user.tv_series_viewings.new(
      title: params[:title],
      show_id: params[:show_id],
      url: tv_series_path(show_id: params[:show_id]),
      started_at: Time.current
    )

    if @tv_series_viewing.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), notice: 'Added to Currently Watching List.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { redirect_to tv_series_path(show_id: params[:show_id]), error: 'Could not add to Currently Watching List.' }
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), error: 'Could not add to Currently Watching List.' }
      end
    end
  end

  def update
    if @tv_series_viewing.update(tv_series_viewing_params)
      @active_tv_series_viewing = current_user.tv_series_viewings.active.find_by(show_id: @tv_series_viewing.show_id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tv_series_viewings_path, notice: 'Removed from Currently Watching List.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { redirect_to tv_series_path(show_id: params[:show_id]), error: 'Could not remove from Currently Watching List.' }
        format.html { redirect_to tv_series_viewings_path, error: 'Could not remove from Currently Watching List.' }
      end
    end
  end

  def destroy
    @tv_series_viewing.destroy
    redirect_to tv_series_viewings_path, notice: 'Successfully deleted viewing.'
  end

  private

  def set_tv_series_viewing
    @tv_series_viewing = current_user.tv_series_viewings.find(params[:id])
  end

  def tv_series_viewing_params
    params.require(:tv_series_viewing).permit(:show_id, :title, :started_at, :ended_at, :user_id)
  end
end
