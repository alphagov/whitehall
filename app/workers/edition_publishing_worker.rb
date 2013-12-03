class EditionPublishingWorker
  class ScheduledPublishingFailure < StandardError; end

  def perform(edition_id, user_id)
    user = User.find(user_id)
    edition = Edition.find(edition_id)
    publish_edition_as_user(edition, user) unless edition.published?
  end

  private

  def publish_edition_as_user(edition, user)
    Edition::AuditTrail.acting_as(user) do
      perform_atomic_update do
        publisher = Whitehall.edition_services.scheduled_publisher(edition)
        unless publisher.perform!
          raise ScheduledPublishingFailure, publisher.failure_reason
        end
      end
    end
  end

  # NOTE: Once this is being run as a proper background job, there should be
  # only one worker processing the job, meaning we won't have to worry about
  # contention and this code can be removed.
  # Also note that the isolation level is set for the next transaction only.
  # It will automatically revert back after the next transaction completes.
  def perform_atomic_update(&block)
    Edition.connection.execute "set transaction isolation level serializable"
    Edition.connection.transaction do
      yield
    end
  end
end
