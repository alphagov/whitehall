class Admin::UsersController < Admin::BaseController
  before_action :load_user, only: %i[show edit update]

  def index
    @users = User.enabled.includes(organisation: [:translations]).sort_by { |u| u.fuzzy_last_name.downcase }
  end

  def show; end

  def edit
    head :forbidden unless @user.editable_by?(current_user)
  end

  def update
    unless @user.editable_by?(current_user)
      head :forbidden
      return
    end

    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Your settings have been saved"
    else
      render action: "edit"
    end
  end

private

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    { world_location_ids: [] }.merge(
      params.require(:user).permit(world_location_ids: []),
    )
  end
end
