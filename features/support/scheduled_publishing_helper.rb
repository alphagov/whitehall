require 'sidekiq/api'

module ScheduledPublishingHelper
  def execute_scheduled_publication_job_for(edition)
    job = scheduled_publishing_job_for(edition)
    set_govuk_headers(job)

    worker = ScheduledPublishingWorker.new
    worker.jid = job.jid
    worker.perform(*job.args)
  end

  def scheduled_publishing_job_for(edition)
    Sidekiq::ScheduledSet.new.detect do |job|
      job.args[0] == edition.id &&
        job.klass == 'ScheduledPublishingWorker'
    end
  end

  def set_govuk_headers(job)
    last_arg = job.args.last

    if last_arg.is_a?(Hash) && last_arg.keys.include?("request_id")
      job.args.pop
      request_id = last_arg["request_id"]
      authenticated_user = last_arg["authenticated_user"]
      GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id)
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, authenticated_user)
    end
  end
end

World(ScheduledPublishingHelper)
