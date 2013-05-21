require 'test_helper'

class EditionPublishingWorkerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  setup { DatabaseCleaner.clean_with :truncation}
  teardown { DatabaseCleaner.clean_with :truncation }

  test '#perform will publish a scheduled edition as a user' do
    edition = create(:edition, :scheduled, scheduled_publication: 1.day.ago)
    user = create(:scheduled_publishing_robot)

    EditionPublishingWorker.new.perform(edition.id, user.id)
    assert_equal :published, edition.reload.current_state
    assert_equal user, edition.latest_version_audit_entry_for('published').actor
  end

  test '#perform will not do anything to an already-published edition' do
    edition = create(:edition, :published)
    edition.expects(:publish_as).never
    user = create(:scheduled_publishing_robot)

    EditionPublishingWorker.new.perform(edition.id, user.id)
    assert_equal :published, edition.reload.current_state
  end

  test '#perform raises an exception when publishing fails' do
    edition = create(:edition, :scheduled, scheduled_publication: 1.day.ago)
    unprivileged_user = create(:user)

    exception = assert_raises(EditionPublishingWorker::ScheduledPublishingFailure) do
      EditionPublishingWorker.new.perform(edition.id, unprivileged_user.id)
    end

    assert_equal 'User must have permission to publish scheduled publications', exception.message
    assert_equal :scheduled, edition.reload.current_state
  end

  test '#perform sets the transaction isolation level to SERIALIZABLE to ensure atomic update' do
    flunk "Fails on user eager loading, need to review and see if this is still needed"
    edition = create(:edition, :scheduled, scheduled_publication: 1.day.ago)
    user = create(:scheduled_publishing_robot)

    atomic_publishing = sequence('atomic publishing')
    Edition.connection.expects(:execute).with("set transaction isolation level serializable").in_sequence(atomic_publishing)
    Edition.connection.expects(:transaction).returns(true).in_sequence(atomic_publishing)

    EditionPublishingWorker.new.perform(edition.id, user.id)
  end
end
