class Admin::Export::BaseController < Admin::BaseController
  before_action :require_export_data_permission!
  respond_to :json

private

  def require_export_data_permission!
    forbidden! unless current_user.can_export_data?
  end

  def forbidden!
    respond_with Hash.new, status: :forbidden
  end
end
