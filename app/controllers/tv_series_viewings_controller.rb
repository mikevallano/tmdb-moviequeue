class TVSeriesViewingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @viewings = current_user.tv_series_viewings
  end

  def create
    @viewing = current_user.tv_series_viewings.new(
      title: params[:title],
      show_id: params[:show_id],
      url: tv_series_path(show_id: params[:show_id]),
      started_at: Time.current
    )

    respond_to do |format|
      if @viewing.save
        format.turbo_stream {}
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), notice: 'Added to Currently Watching List.' }
      else
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), error: 'Could not add to Currently Watching List.' }
      end
    end
  end

  def update
    @viewing = current_user.tv_series_viewings.active.find_by(show_id: params[:show_id])

    respond_to do |format|
      if @viewing.update(ended_at: Time.current)
        format.turbo_stream {}
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), notice: 'Removed from Currently Watching List.' }
      else
        format.html { redirect_to tv_series_path(show_id: params[:show_id]), error: 'Could not remove from Currently Watching List.' }
      end
    end
  end
end
