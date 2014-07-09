require 'test_helper'

class ScheduledPublishingWorkerTest < ActiveSupport::TestCase
  setup do
    @publishing_robot = create(:scheduled_publishing_robot)
  end

  test '#perform publishes a scheduled edition as the publishing robot' do
    edition = create(:scheduled_edition, scheduled_publication: 1.second.ago)
    stub_panopticon_registration(edition)
    ScheduledPublishingWorker.new.perform(edition.id)

    assert edition.reload.published?
    assert_equal @publishing_robot, edition.latest_version_audit_entry_for('published').actor
  end

  test '#perform raises an error if the edition cannot be published' do
    edition = create(:superseded_edition)

    exception = assert_raise(ScheduledPublishingWorker::ScheduledPublishingFailure) do
      ScheduledPublishingWorker.new.perform(edition.id)
    end

    assert_equal 'Only scheduled editions can be published with ScheduledEditionPublisher', exception.message
    assert edition.reload.superseded?
  end

  test '.queue queues a job for a scheduled edition' do
    edition = create(:scheduled_edition)

    Sidekiq::Testing.fake! do
      ScheduledPublishingWorker.queue(edition)

      assert job = ScheduledPublishingWorker.jobs.last
      assert_equal edition.id, job["args"].first
      assert_equal edition.scheduled_publication.to_i, job["at"].to_i
    end
  end
end
