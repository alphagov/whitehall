class Admin::AuthorsController < Admin::BaseController
  layout "design_system"

  def show
    @user = User.find(params[:id])
  end
end
