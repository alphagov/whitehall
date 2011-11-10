class Admin::RolesController < Admin::BaseController
  def index
    @roles = Role.order(:name)
  end
end