class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  private

  def authenticate!
    unless current_user
      redirect_to login_path, alert: "You're not authorised to view this page"
    end
  end

  def current_user
    User.find_by_id(session[:user_id])
  end
end
