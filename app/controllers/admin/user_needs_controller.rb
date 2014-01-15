class Admin::UserNeedsController < Admin::BaseController
  def create
    user_need = UserNeed.new(user_need_params)

    if user_need.save
      render json: { id: user_need.id, text: user_need.to_s }
    else
      render json: { errors: user_need.errors }, status: 422
    end
  end

private
  def user_need_params
    params.require(:user_need).permit(:user, :need, :goal)
  end
end
