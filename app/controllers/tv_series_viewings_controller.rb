class TVSeriesViewingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @viewings = current_user.tv_series_viewings
  end
end
