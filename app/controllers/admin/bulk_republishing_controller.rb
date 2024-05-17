class Admin::BulkRepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def confirm_all
    bulk_content_type = RepublishingEvent.bulk_content_types[params[:bulk_content_type]]

    return render "admin/errors/not_found", status: :not_found unless bulk_content_type

    # should we add an index to this field in order to improve performance of this query?
    last_republishing_event_of_type = RepublishingEvent.order(created_at: :desc).find_by(bulk_content_type:)
    job_recently_queued = last_republishing_event_of_type&.created_at&.> Time.zone.now.ago(1.hour)
    @recently_queued_job_time = job_recently_queued ? last_republishing_event_of_type.created_at.strftime("%l:%M%P").strip : nil
    @suggested_requeue_time = job_recently_queued ? last_republishing_event_of_type.created_at.advance(hours: 1).strftime("%l:%M%P").strip : nil
    @republishing_event = RepublishingEvent.new(reason: params[:reason])
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
