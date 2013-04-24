class Admin::GetInvolvedController < Admin::BaseController
  before_filter :enforce_permissions!

  def enforce_permissions!
    enforce_permission!(:administer, :get_involved_section)
  end

  def index
  end
end
