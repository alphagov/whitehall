class Admin::UserNeedsController < Admin::BaseController
  def create
    user_need = UserNeed.new(params[:user_need])

    if user_need.save
      render json: { id: user_need.id, text: user_need.to_s }
    else
      render json: { errors: user_need.errors }, status: 422
    end
  end
end

