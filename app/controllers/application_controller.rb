class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  
  def authenticate!
    unless current_user
      flash[:warning] = "You're not authorised to view this page" 
      redirect_to login_path
    end
  end
  
  def current_user
    User.find_by_id(session[:user_id])
  end
end
