class Admin::UserNeedsController < Admin::BaseController
  def create
    user_need = UserNeed.create(params[:user_need])
    render json: { id: user_need.id, text: user_need.to_s }
  end
end

