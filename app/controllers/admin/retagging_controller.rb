class Admin::RetaggingController < Admin::BaseController
  include ActionView::Helpers::SanitizeHelper
  # include ReshuffleMode # TODO: don't allow retagging while a reshuffle is in progress

  before_action :enforce_permissions!

  def index; end

  def preview
    updater = DataHygiene::BulkOrganisationUpdater.new(params[:csv_input])
    updater.validate

    if updater.errors.any?
      sanitized_errors = updater.errors.map { |err| sanitize(err) }
      flash[:alert] = "Errors with CSV input: <br>#{sanitized_errors.join('<br>')}".html_safe
      render :index
    end
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :retag_content)
  end
end
