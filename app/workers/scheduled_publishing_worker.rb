require 'sidekiq/api'

class ScheduledPublishingWorker < WorkerBase
  class ScheduledPublishingFailure < StandardError; end

  sidekiq_options queue: :scheduled_publishing

  def self.queue(edition)
    perform_at(edition.scheduled_publication, edition.id)
  end

  def self.dequeue(edition)
    Sidekiq::ScheduledSet.new.select do |joby|
      joby['class'] == name && joby.args[0] == edition.id
    end.map(&:delete)
  end

  # Only used by the publishing:scheduled:requeue_all_jobs rake task.
  def self.dequeue_all
    queued_jobs.map(&:delete)
  end

  def self.queue_size
    queued_jobs.size
  end

  def self.queued_edition_ids
    queued_jobs.map { |job| job['args'][0] }
  end

  def perform(edition_id)
    edition = Edition.find(edition_id)
    return if edition.published?

    publisher = Whitehall.edition_services.scheduled_publisher(edition)

    Edition::AuditTrail.acting_as(publishing_robot) do
      publisher.perform! or raise ScheduledPublishingFailure, publisher.failure_reason
    end
  end

private

  def self.queued_jobs
    Sidekiq::ScheduledSet.new.select { |job| job['class'] == name }
  end

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end
end
