class EditionPublishingWorker
  class ScheduledPublishingFailure < StandardError; end

  def perform(edition_id, user_id)
    user = User.find(user_id)
    edition = Edition.find(edition_id)
    publish_edition_as_user(edition, user) unless edition.published?
  end

  private

  def publish_edition_as_user(edition, user)
    with_audit_trail_for(user) do
      perform_atomic_update do
        if !edition.publish_as(user)
          raise ScheduledPublishingFailure, edition.errors.full_messages.to_sentence
        end
      end
    end
  end

  def with_audit_trail_for(user, &block)
    original_user = Edition::AuditTrail.whodunnit
    Edition::AuditTrail.whodunnit = user
    yield
  ensure
    Edition::AuditTrail.whodunnit = original_user
  end

  # NOTE: Once this is being run as a proper background job, there should be
  # only one worker processing the job, meaning we won't have to worry about
  # contention and this code can be removed.
  def perform_atomic_update(&block)
    Edition.connection.execute "set transaction isolation level serializable"
    Edition.connection.transaction do
      yield
    end
  end
end
