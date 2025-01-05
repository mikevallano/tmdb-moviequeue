class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit]
  before_action :restrict_to_content_owner!, only: [:show, :edit]

  def show
    if request.path != user_path(@user)
      return redirect_to user_path(@user), status: :moved_permanently
    end
  end

  def edit
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
