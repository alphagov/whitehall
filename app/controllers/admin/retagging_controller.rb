class Admin::RetaggingController < Admin::BaseController
  # TODO: replicate or reuse DataHygiene::BulkOrganisationUpdater
  # include ReshuffleMode # TODO: don't allow retagging while a reshuffle is in progress

  before_action :enforce_permissions!

  def index; end

private

  def enforce_permissions!
    enforce_permission!(:administer, :retag_content)
  end
end
