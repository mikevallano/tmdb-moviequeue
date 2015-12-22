class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.friendly.find(params[:id])
    unless current_user == @user
      redirect_to root_path, notice: "That's not your page"
    end
  end
end
