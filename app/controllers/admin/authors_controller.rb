class Admin::AuthorsController < Admin::BaseController
  layout "bootstrap_admin"

  def show
    @user = User.find(params[:id])
  end
end
