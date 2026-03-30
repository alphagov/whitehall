require "test_helper"

class ScheduledPublishingJobTest < ActiveSupport::TestCase
  setup do
    @publishing_robot = create(:scheduled_publishing_robot)
  end

  test "#perform publishes a scheduled edition as the publishing robot" do
    edition = create(:scheduled_edition, scheduled_publication: 1.second.ago)

    stub_publishing_api_registration_for(edition)
    ScheduledPublishingJob.new.perform(edition.id)

    assert edition.reload.published?
    assert_equal @publishing_robot, edition.published_by
  end

  test "#perform raises an error if the edition cannot be published" do
    edition = create(:superseded_edition)

    Whitehall.edition_services.expects(:scheduled_publisher).never

    ScheduledPublishingJob.new.perform(edition.id)

    assert edition.reload.superseded?
  end

  test "#perform returns without consequence if the edition is already published" do
    edition = create(:published_edition)
    assert_nil ScheduledPublishingJob.new.perform(edition.id)
  end

  test ".queue queues a job for a scheduled edition" do
    edition = create(:scheduled_edition)

    ScheduledPublishingJob.queue(edition)

    assert job = ScheduledPublishingJob.jobs.last
    assert_equal edition.id, job["args"].first
    assert_equal edition.scheduled_publication.to_i, job["at"].to_i
  end

  test ".dequeue removes a job for a scheduled edition" do
    edition = create(:scheduled_edition)
    target_job = mock("target_job")
    target_job.stubs(:[]).with("class").returns(ScheduledPublishingJob.name)
    target_job.stubs(:args).returns([edition.id])
    target_job.expects(:delete).once

    keep_job = mock("keep_job")
    keep_job.stubs(:[]).with("class").returns(ScheduledPublishingJob.name)
    keep_job.stubs(:args).returns([-1])
    keep_job.expects(:delete).never

    Sidekiq::ScheduledSet.stubs(:new).returns([target_job, keep_job])
    ScheduledPublishingJob.dequeue(edition)
  end

  test ".dequeue_all removes all scheduled publishing jobs" do
    job_one = mock("job_one")
    job_one.stubs(:[]).with("class").returns(ScheduledPublishingJob.name)
    job_one.expects(:delete).once

    job_two = mock("job_two")
    job_two.stubs(:[]).with("class").returns(ScheduledPublishingJob.name)
    job_two.expects(:delete).once

    other_job = mock("other_job")
    other_job.stubs(:[]).with("class").returns("SomeOtherjob")
    other_job.expects(:delete).never

    Sidekiq::ScheduledSet.stubs(:new).returns([job_one, job_two, other_job])
    ScheduledPublishingJob.dequeue_all
  end

  test ".queue_size returns the number of queued ScheduledPublishingJob jobs" do
    ScheduledPublishingJob.stubs(:queued_jobs).returns([Object.new, Object.new])
    assert_equal 2, ScheduledPublishingJob.queue_size
  end

  test ".queued_edition_ids returns the edition ids of the currently queued jobs" do
    ScheduledPublishingJob.stubs(:queued_jobs).returns([{ "args" => %w[3] }, { "args" => %w[6] }])
    assert_same_elements %w[3 6], ScheduledPublishingJob.queued_edition_ids
  end
end
