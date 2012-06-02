class Admin::UsersController < Admin::BaseController
  before_filter :load_user, only: [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to admin_user_path, notice: "Your settings have been saved"
    else
      render action: "edit"
    end
  end

  private

  def load_user
    @user = current_user
  end
end
