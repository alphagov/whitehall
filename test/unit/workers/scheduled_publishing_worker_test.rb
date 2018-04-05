require 'test_helper'

class ScheduledPublishingWorkerTest < ActiveSupport::TestCase
  include SidekiqTestHelpers

  setup do
    @publishing_robot = create(:scheduled_publishing_robot)
  end

  test '#perform publishes a scheduled edition as the publishing robot' do
    edition = create(:scheduled_edition, scheduled_publication: 1.second.ago)

    stub_publishing_api_registration_for(edition)
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

  test '#perform returns without consequence if the edition is already published' do
    edition = create(:published_edition)
    ScheduledPublishingWorker.new.perform(edition.id)
  end

  test '.queue queues a job for a scheduled edition' do
    edition = create(:scheduled_edition)

    ScheduledPublishingWorker.queue(edition)

    assert job = ScheduledPublishingWorker.jobs.last
    assert_equal edition.id, job["args"].first
    assert_equal edition.scheduled_publication.to_i, job["at"].to_i
  end

  test '.dequeue removes a job for a scheduled edition' do
    control = create(:scheduled_edition)
    edition = create(:scheduled_edition)

    with_real_sidekiq do
      ScheduledPublishingWorker.queue(edition)
      ScheduledPublishingWorker.queue(control)

      assert_equal 2, Sidekiq::ScheduledSet.new.size

      ScheduledPublishingWorker.dequeue(edition)

      assert_equal 1, Sidekiq::ScheduledSet.new.size

      assert Sidekiq::ScheduledSet.new.detect do |job|
        control.id == job['args'].first &&
          control.scheduled_publication.to_i == job.at.to_i
      end
    end
  end

  test '.dequeue_all removes all scheduled publishing jobs' do
    edition_1 = create(:scheduled_edition)
    edition_2 = create(:scheduled_edition)

    with_real_sidekiq do
      ScheduledPublishingWorker.queue(edition_1)
      ScheduledPublishingWorker.queue(edition_2)

      assert_equal 2, Sidekiq::ScheduledSet.new.size

      ScheduledPublishingWorker.dequeue_all

      assert_equal 0, Sidekiq::ScheduledSet.new.size
    end
  end

  test '.queue_size returns the number of queued ScheduledPublishingWorker jobs' do
    with_real_sidekiq do
      ScheduledPublishingWorker.perform_at(1.day.from_now, 'null')
      assert_equal 1, ScheduledPublishingWorker.queue_size

      ScheduledPublishingWorker.perform_at(2.days.from_now, 'null')
      assert_equal 2, ScheduledPublishingWorker.queue_size
    end
  end

  test '.queued_edition_ids returns the edition ids of the currently queued jobs' do
    with_real_sidekiq do
      ScheduledPublishingWorker.perform_at(1.day.from_now, '3')
      ScheduledPublishingWorker.perform_at(2.days.from_now, '6')

      assert_same_elements %w[3 6], ScheduledPublishingWorker.queued_edition_ids
    end
  end
end
