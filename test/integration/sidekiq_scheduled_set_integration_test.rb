require "test_helper"

class SidekiqScheduledSetIntegrationTest < ActiveSupport::TestCase
  include SidekiqTestHelpers

  test "ScheduledPublishingWorker uses real scheduled set with Redis" do
    with_real_sidekiq do
      ScheduledPublishingWorker.perform_at(1.day.from_now, "1")
      ScheduledPublishingWorker.perform_at(2.days.from_now, "2")

      assert_equal 2, ScheduledPublishingWorker.queue_size
      assert_same_elements %w[1 2], ScheduledPublishingWorker.queued_edition_ids

      ScheduledPublishingWorker.dequeue(Struct.new(:id).new("1"))

      assert_equal 1, ScheduledPublishingWorker.queue_size
      assert_equal %w[2], ScheduledPublishingWorker.queued_edition_ids
    end
  end
end
