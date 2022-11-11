require "test_helper"

class ScheduledPublishingWorkerTest < ActiveSupport::TestCase
  include SidekiqTestHelpers

  setup do
    @publishing_robot = create(:scheduled_publishing_robot)
  end

  test "#perform publishes a scheduled edition as the publishing robot" do
    edition = create(:scheduled_edition, scheduled_publication: 1.second.ago)

    stub_publishing_api_registration_for(edition)
    ScheduledPublishingWorker.new.perform(edition.id)

    assert edition.reload.published?
    assert_equal @publishing_robot, edition.published_by
  end

  test "#perform raises an error if the edition cannot be published" do
    edition = create(:superseded_edition)

    Whitehall.edition_services.expects(:scheduled_publisher).never

    ScheduledPublishingWorker.new.perform(edition.id)

    assert edition.reload.superseded?
  end

  test "#perform returns without consequence if the edition is already published" do
    edition = create(:published_edition)
    ScheduledPublishingWorker.new.perform(edition.id)
  end

  test ".queue queues a job for a scheduled edition" do
    edition = create(:scheduled_edition)

    ScheduledPublishingWorker.queue(edition)

    assert job = ScheduledPublishingWorker.jobs.last
    assert_equal edition.id, job["args"].first
    assert_equal edition.scheduled_publication.to_i, job["at"].to_i
  end

  test ".dequeue removes a job for a scheduled edition" do
    edition = create(:scheduled_edition)

    edition_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition.id])
    control_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition.id + 1])
    Sidekiq::ScheduledSet.stubs(:new).returns([edition_job, control_job])

    edition_job.expects(:delete)

    ScheduledPublishingWorker.dequeue(edition)
  end

  test ".dequeue_all removes all scheduled publishing jobs" do
    edition1 = create(:scheduled_edition)
    edition2 = create(:scheduled_edition)

    edition1_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition1.id])
    edition2_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition2.id])
    Sidekiq::ScheduledSet.stubs(:new).returns([edition1_job, edition2_job])

    edition1_job.expects(:delete)
    edition2_job.expects(:delete)

    ScheduledPublishingWorker.dequeue_all
  end

  test ".queue_size returns the number of queued ScheduledPublishingWorker jobs" do
    edition1 = create(:scheduled_edition)
    edition2 = create(:scheduled_edition)

    edition1_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition1.id])
    edition2_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition2.id])
    Sidekiq::ScheduledSet.stubs(:new).returns([edition1_job, edition2_job])

    assert_equal 2, ScheduledPublishingWorker.queue_size
  end

  test ".queued_edition_ids returns the edition ids of the currently queued jobs" do
    edition1 = create(:scheduled_edition)
    edition2 = create(:scheduled_edition)

    edition1_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition1.id])
    edition2_job = Sidekiq::SortedEntry.new({}, 1, "class" => "ScheduledPublishingWorker", "args" => [edition2.id])
    Sidekiq::ScheduledSet.stubs(:new).returns([edition1_job, edition2_job])

    assert_same_elements [edition1.id, edition2.id], ScheduledPublishingWorker.queued_edition_ids
  end
end
