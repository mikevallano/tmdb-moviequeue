class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update]
  before_action :restrict_to_content_owner!, only: [:show, :edit, :update]

  def show
    if request.path != user_path(@user)
      return redirect_to user_path(@user), status: :moved_permanently
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      selected_streaming_service_provider_ids = params[:user][:streaming_service_provider_ids]

      if selected_streaming_service_provider_ids.any?
        @user.user_streaming_service_providers.delete_all
        selected_streaming_service_provider_ids.reject(&:blank?).each do |id|
          @user.user_streaming_service_providers.create!(streaming_service_provider_id: id)
        end
      end
      redirect_to user_url(@user), notice: "Settings Updated"
    else
      render :edit, alert: 'Failed to update preferences.'
    end
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :slug, :default_location)
  end
end
