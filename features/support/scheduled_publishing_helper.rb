require 'sidekiq/api'

module ScheduledPublishingHelper
  def execute_scheduled_publication_job_for(edition)
    job = scheduled_publishing_job_for(edition)

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
end

World(ScheduledPublishingHelper)
