class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_name(params[:name])
    session[:user_id] = user.id
    render :nothing => true
  end
end