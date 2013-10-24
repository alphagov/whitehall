require 'test_helper'

class EditionPublishingWorkerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  setup do
    DatabaseCleaner.clean_with :truncation
    @publishing_robot = create(:scheduled_publishing_robot)
  end
  teardown { DatabaseCleaner.clean_with :truncation }

  test '#perform will publish a scheduled edition as a user' do
    edition = create(:edition, :scheduled, scheduled_publication: 1.day.ago)

    EditionPublishingWorker.new.perform(edition.id, @publishing_robot.id)
    assert_equal :published, edition.reload.current_state
    assert_equal @publishing_robot, edition.latest_version_audit_entry_for('published').actor
  end

  test '#perform will not do anything to an already-published edition' do
    edition = create(:edition, :published)
    edition.expects(:publish!).never

    EditionPublishingWorker.new.perform(edition.id, @publishing_robot.id)
    assert_equal :published, edition.reload.current_state
  end

  test '#perform raises an exception when publishing fails' do
    edition = create(:archived_edition)

    exception = assert_raise(EditionPublishingWorker::ScheduledPublishingFailure) do
      EditionPublishingWorker.new.perform(edition.id, @publishing_robot.id)
    end

    assert_equal 'An edition that is archived cannot be published', exception.message
    assert edition.reload.archived?
  end
end
