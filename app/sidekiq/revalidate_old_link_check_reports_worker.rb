class RevalidateOldLinkCheckReportsWorker
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
    GovukStatsd.time("link-checking-debug.revalidate-old-link-check-reports-worker") do
      editions = least_recently_checked_editions
      logger.info("[link-checking-debug][job_#{jid}]: Requesting link checks for #{editions.count} out of #{public_editions.count} editions")

      rechecked = 0 # editions that have links and are being rechecked
      touched = 0 # editions that have no links and are just having their 'updated_at' updated
      editions.find_each(batch_size: FIND_EACH_BATCH_SIZE) do |edition|
        if LinkCheckerApiService.has_links?(edition)
          LinkCheckerApiService.check_links(edition, admin_link_checker_api_callback_url(host: Plek.find("whitehall-admin")))
          rechecked += 1
        else
          LinkCheckerApiReport.create_noop_report(edition)
          touched += 1
        end
      end
      logger.info("[link-checking-debug][job_#{jid}]: Done requesting link checks for #{editions.count}. #{touched} of them were noops, whereas #{rechecked} were rechecked using Link Checker API.")
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
