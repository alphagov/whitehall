class Admin::UserNeedsController < Admin::BaseController
  def create
    user_need = UserNeed.create(params[:user_need])
    obj = {
      id: user_need.id,
      text: user_need.to_s
    }
    render json: obj.to_json
  end
end

