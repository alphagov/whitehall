class Admin::BulkRepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def confirm_all
    bulk_content_type = RepublishingEvent.bulk_content_types[params[:bulk_content_type]]

    return render "admin/errors/not_found", status: :not_found unless bulk_content_type

    @republishing_event = RepublishingEvent.new
    @republishing_path = send("admin_bulk_republishing_#{RepublishingEvent.bulk_content_types.key(bulk_content_type)}_republish_path")
    @bulk_content_type_string = RepublishingEvent.humanised_bulk_content_type(params[:bulk_content_type].to_sym)
  end

  def republish_all_about_us_pages; end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def build_republishing_event(action, bulk_content_type)
    RepublishingEvent.new(user: current_user, reason: params.fetch(:reason), bulk: true, action:, bulk_content_type:)
  end
end
