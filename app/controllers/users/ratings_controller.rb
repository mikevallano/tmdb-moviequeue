class Users::RatingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @ratings = current_user.ratings
      .where(value: 8..Float::INFINITY)
      .order(value: :desc)
      .paginate(:page => params[:page], per_page: 20)
  end
end
