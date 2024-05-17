class Admin::BulkRepublishingController < Admin::BaseController
  before_action :enforce_permissions!

  def confirm_all
    bulk_content_type = RepublishingEvent.bulk_content_types[params[:bulk_content_type]]

    return render "admin/errors/not_found", status: :not_found unless bulk_content_type

    check_for_recently_queued_jobs(bulk_content_type)
    @republishing_event = RepublishingEvent.new(reason: params[:reason])
    @republishing_path = send("admin_bulk_republishing_#{RepublishingEvent.bulk_content_types.key(bulk_content_type)}_republish_path")
    @bulk_content_type_string = RepublishingEvent.humanised_bulk_content_type(params[:bulk_content_type].to_sym)
  end

  def republish_all_about_us_pages
    bulk_content_type = RepublishingEvent.bulk_content_types["all_about_us_pages"]
    check_for_recently_queued_jobs(bulk_content_type)

    if @recently_queued_job_time && params[:confirm_requeue] != "1"
      flash[:alert] = "You must confirm that you wish to requeue this recently queued job"
      return redirect_to(admin_bulk_republishing_all_confirm_path("all_about_us_pages"))
    end

    action = "All about us pages have been scheduled for republishing"

    # make the remainder a transaction so that the republishing event isn't saved if there's an error during scheduling? Do the same in the other controller?
    @republishing_event = build_republishing_event(action, bulk_content_type)

    # we should probably do this in the other controller too:
    # if we encounter some kind of error while queueing the jobs, without this
    # we'll not roll back the event, so we'll have a recorded event but no
    # associated queued jobs (misleading)
    ActiveRecord::Base.transaction do
      if @republishing_event.save
        about_us_page_documents_ids = Organisation.all.map(&:about_us).compact.pluck(:document_id)

        about_us_page_documents_ids.each do |about_us_page_documents_id|
          PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
            "bulk_republishing",
            about_us_page_documents_id,
            true,
          )
        end

        flash[:notice] = action

        redirect_to(admin_republishing_index_path)
      else
        @republishing_path = admin_bulk_republishing_all_about_us_pages_republish_path
        @bulk_content_type_string = RepublishingEvent.humanised_bulk_content_type(:all_about_us_pages)

        render "confirm_all"
      end
    end
  # I'm not sure if we need the rescue, but it might be nice to let people know
  # if there's an error and the queueing has failed, so that they aren't worried
  # about double queuing. I'm not sure that we can be more specific than
  # StandardError
  rescue StandardError
    @republishing_path = admin_bulk_republishing_all_about_us_pages_republish_path
    @bulk_content_type_string = RepublishingEvent.humanised_bulk_content_type(:all_about_us_pages)
    flash[:alert] = "An error occured. The republishing job has not been queued."

    render "confirm_all"
  end

private

  def check_for_recently_queued_jobs(bulk_content_type)
    last_republishing_event_of_type = RepublishingEvent.last_of_type(bulk_content_type)
    if last_republishing_event_of_type.recently_queued?
      @recently_queued_job_time = last_republishing_event_of_type.created_at.strftime("%l:%M%P").strip
      @suggested_requeue_time = last_republishing_event_of_type.created_at.advance(hours: 1).strftime("%l:%M%P").strip
    else
      @recently_queued_job_time, @suggested_requeue_time = nil
    end
  end

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def build_republishing_event(action, bulk_content_type)
    RepublishingEvent.new(user: current_user, reason: params.fetch(:reason), bulk: true, action:, bulk_content_type:)
  end
end
