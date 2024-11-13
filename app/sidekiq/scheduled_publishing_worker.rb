require "sidekiq/api"

# ScheduledPublishingWorker is a job that is scheduled by the `EditionScheduler`.
# It is never executed immediately but uses the Sidekiq delay mechanism to
# execute at the time the edition should be published.
class ScheduledPublishingWorker < WorkerBase
  ScheduledPublishingFailure = Class.new(StandardError)

  class << self
    def queue(edition)
      perform_at(edition.scheduled_publication, edition.id)
    end

    def dequeue(edition)
      Sidekiq::ScheduledSet
        .new
        .select { |joby| joby["class"] == name && joby.args[0] == edition.id }
        .map(&:delete)
    end

    # Only used by the publishing:scheduled:requeue_all_jobs rake task.
    def dequeue_all
      queued_jobs.map(&:delete)
    end

    def queue_size
      queued_jobs.size
    end

    def queued_edition_ids
      queued_jobs.map { |job| job["args"][0] }
    end

  private

    def queued_jobs
      Sidekiq::ScheduledSet.new.select { |job| job["class"] == name }
    end
  end

  sidekiq_options queue: :scheduled_publishing

  def perform(edition_id)
    edition = Edition.find(edition_id)
    return if edition.published? || !edition.scheduled?

    # Call `ScheduledEditionPublisher` via the `EditionServiceCoordinator`.
    publisher = Whitehall.edition_services.scheduled_publisher(edition)

    AuditTrail.acting_as(publishing_robot) do
      publisher.perform! || raise(ScheduledPublishingFailure, publisher.failure_reason)
    end
  end

private

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end
end
