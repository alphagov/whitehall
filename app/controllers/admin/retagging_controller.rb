class Admin::RetaggingController < Admin::BaseController
  include ActionView::Helpers::SanitizeHelper
  # include ReshuffleMode # TODO: don't allow retagging while a reshuffle is in progress

  before_action :enforce_permissions!

  def index; end

  def preview
    updater = DataHygiene::BulkOrganisationUpdater.new(params[:csv_input])
    updater.validate

    if updater.errors.any?
      set_flash_alert(updater.errors)
      render :index
    else
      @docs_to_update = updater.summarise_changes
    end
  end

  def publish
    updater = DataHygiene::BulkOrganisationUpdater.new(params[:csv_input])
    updater.validate

    if updater.errors.any?
      set_flash_alert(updater.errors)
    else
      updater.call
      flash[:notice] = "Retagging in progress."
    end
    redirect_to(admin_retagging_index_path)
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :retag_content)
  end

  def set_flash_alert(errors)
    sanitized_errors = errors.map { |err| sanitize(err) }
    flash[:alert] = "Errors with CSV input: <br>#{sanitized_errors.join('<br>')}".html_safe
  end
end
