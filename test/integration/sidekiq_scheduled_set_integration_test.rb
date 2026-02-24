require "test_helper"

class SidekiqScheduledSetIntegrationTest < ActiveSupport::TestCase
  include SidekiqTestHelpers

  test "ScheduledPublishingJob uses real scheduled set with Redis" do
    with_real_sidekiq do
      ScheduledPublishingJob.perform_at(1.day.from_now, "1")
      ScheduledPublishingJob.perform_at(2.days.from_now, "2")

      assert_equal 2, ScheduledPublishingJob.queue_size
      assert_same_elements %w[1 2], ScheduledPublishingJob.queued_edition_ids

      ScheduledPublishingJob.dequeue(Struct.new(:id).new("1"))

      assert_equal 1, ScheduledPublishingJob.queue_size
      assert_equal %w[2], ScheduledPublishingJob.queued_edition_ids
    end
  end
end
