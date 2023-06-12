class Admin::GetInvolvedController < Admin::BaseController
  before_action :enforce_permissions!
  layout "design_system"

  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index; end
end
