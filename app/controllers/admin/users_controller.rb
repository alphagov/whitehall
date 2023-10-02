class Admin::UsersController < Admin::BaseController
  before_action :load_user, only: %i[show edit update]
  layout :get_layout

  def index
    @users = User.enabled.includes(organisation: [:translations]).sort_by { |u| u.fuzzy_last_name.downcase }
    render_design_system(:index, :legacy_index)
  end

  def show
    render_design_system(:show, :legacy_show)
  end

  def edit
    unless @user.editable_by?(current_user)
      head :forbidden
      return
    end
    render_design_system(:edit, :legacy_edit)
  end

  def update
    unless @user.editable_by?(current_user)
      head :forbidden
      return
    end

    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "World locations have been updated"
    else
      render_design_system(:edit, :legacy_edit)
    end
  end

private

  def get_layout
    design_system_actions = %w[index show edit] if preview_design_system?(next_release: false)

    if design_system_actions&.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    { world_location_ids: [] }.merge(
      params.require(:user).permit(world_location_ids: []),
    )
  end
end
