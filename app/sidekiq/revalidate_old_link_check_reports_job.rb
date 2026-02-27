class RevalidateOldLinkCheckReportsJob
  include Rails.application.routes.url_helpers
  include Sidekiq::Job
  MAX_REPORTS_TO_CHECK = 60_000
  FIND_EACH_BATCH_SIZE = 50

  sidekiq_options queue: "link_checks", retry: 6
  # Stop retrying jobs within a day as new jobs are enqueued each day,
  # and also retry less times within a day as this isn't a critical
  # task.
  sidekiq_retry_in do |retry_count, _exception|
    # First retry in 15 seconds, 6th (and last) retry at ~5 hours
    ((0.5 * (retry_count + 1)**4) * 30)
  end

  def perform
    GovukStatsd.time("link-checking-debug.revalidate-old-link-check-reports-job") do
      editions = least_recently_checked_editions
      logger.info("[link-checking-debug][job_#{jid}]: Requesting link checks for #{editions.count} out of #{public_editions.count} editions")

      editions.find_each(batch_size: FIND_EACH_BATCH_SIZE) do |edition|
        RevalidateLinkCheckReportJob.perform_async(edition.id)
      end
      logger.info("[link-checking-debug][job_#{jid}]: Done requesting link checks for #{editions.count}")
    end
  end

private

  def public_editions
    Edition.includes(:link_check_report).publicly_visible.with_translations
  end

  def least_recently_checked_editions
    least_recently_checked = public_editions.order("link_checker_api_reports.updated_at").limit(MAX_REPORTS_TO_CHECK)
    Edition.where(id: least_recently_checked.pluck(:id))
  end
end
