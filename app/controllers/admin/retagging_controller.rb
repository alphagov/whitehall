class Admin::RetaggingController < Admin::BaseController
  before_action :enforce_permissions!

  def index; end

private
  def enforce_permissions!
    enforce_permission!(:administer, :retag_documents)
  end
end