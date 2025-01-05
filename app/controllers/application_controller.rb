class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception
  before_action :set_sentry_context
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected

  def restrict_to_admin!
    return if current_user.admin?
    redirect_back(fallback_location: root_path, alert: 'Must be an admin to access that feature')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation, :remember_me])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :username, :email, :password, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username, :email, :default_location, :password, :password_confirmation, :current_password])
  end

  def restrict_to_content_owner!
    unless current_user == User.friendly.find(params[:id])
      redirect_to root_path, notice: "That's not your page"
    end
  end

  private

  def set_sentry_context
    counter = (Sentry.get_current_scope.tags[:counter] || 0) + 1
    Sentry.set_tags(counter: counter)
  end
end
