class RevalidateLinkCheckReportJob
  include Rails.application.routes.url_helpers
  include Sidekiq::Job

  sidekiq_options queue: "link_checks", retry: 6
  # Stop retrying jobs within a day as new jobs are enqueued each day,
  # and also retry less times within a day as this isn't a critical
  # task.
  sidekiq_retry_in do |retry_count, _exception|
    # First retry in 15 seconds, 6th (and last) retry at ~5 hours
    ((0.5 * (retry_count + 1)**4) * 30)
  end

  def perform(edition_id)
    edition = Edition.find(edition_id)
    if LinkCheckerApiService.has_links?(edition)
      logger.info("[link-checking-debug][job_#{jid}]: Requesting link checks for Edition #{edition_id}")
      LinkCheckerApiService.check_links(edition, admin_link_checker_api_callback_url(host: Plek.find("whitehall-admin")))
    else
      logger.info("[link-checking-debug][job_#{jid}]: Creating noop link check report Edition #{edition_id}")
      LinkCheckerApiReport.create_noop_report(edition)
    end
  end
end
