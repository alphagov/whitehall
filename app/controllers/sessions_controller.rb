class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_or_create_by_name(params[:name])
    if user.valid?
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:warning] = "Name can't be blank"
      render :new
    end
  end
end