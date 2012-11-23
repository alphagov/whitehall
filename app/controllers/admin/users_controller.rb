class Admin::UsersController < Admin::BaseController
  before_filter :load_user, only: [:show, :edit, :update]

  def index
    @users = User.all
  end

  def show
  end

  def edit
    head :forbidden unless (@user.editable_by?(current_user))
  end

  def update
    unless @user.editable_by?(current_user)
      head :forbidden
      return
    end

    if @user.update_attributes(params[:user])
      redirect_to admin_user_path(@user), notice: "Your settings have been saved"
    else
      render action: "edit"
    end
  end

  private

  def load_user
    @user = User.find(params[:id])
  end
end
