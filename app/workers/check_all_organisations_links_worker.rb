# Enqueues CheckAllEditionsLinksWorker for all organisations
require "sidekiq-scheduler"

class CheckAllOrganisationsLinksWorker
  include Sidekiq::Worker

  def perform
    GovukStatsd.time("link-checking-debug.check-all-organisations-worker") do
      logger.info("[link-checking-debug][job_#{jid}]: Queuing #{organisation_ids.count} jobs to check organisations")
      organisation_ids.each do |organisation_id|
        CheckOrganisationLinksWorker.perform_async(organisation_id)
      end
      logger.info("[link-checking-debug][job_#{jid}]: Done queuing #{organisation_ids.count} jobs to check organisations")
    end
  end

private

  def organisation_ids
    @organisation_ids ||= Organisation.all.pluck(:id)
  end
end
