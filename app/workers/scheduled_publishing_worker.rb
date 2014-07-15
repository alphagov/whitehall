require 'sidekiq/api'

class ScheduledPublishingWorker
  class ScheduledPublishingFailure < StandardError; end

  include Sidekiq::Worker
  sidekiq_options queue: :scheduled_publishing

  def self.queue(edition)
    perform_at(edition.scheduled_publication, edition.id)
  end

  def self.dequeue(edition)
    Sidekiq::ScheduledSet.new.select do |joby|
      joby['class'] == name && joby.args[0] == edition.id
    end.map(&:delete)
  end

  def perform(edition_id)
    edition = Edition.find(edition_id)
    publisher = Whitehall.edition_services.scheduled_publisher(edition)

    Edition::AuditTrail.acting_as(publishing_robot) do
      publisher.perform! or raise ScheduledPublishingFailure, publisher.failure_reason
    end
  end

private

  def publishing_robot
    User.where(name: "Scheduled Publishing Robot", uid: nil).first
  end
end
