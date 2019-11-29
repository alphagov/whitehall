require "test_helper"

class EditionUnschedulerTest < ActiveSupport::TestCase
  test "only a scheduled edition can be unscheduled" do
    edition = build(:scheduled_edition)
    unscheduler = EditionUnscheduler.new(edition)

    assert unscheduler.can_perform?

    edition.publish
    assert_not unscheduler.can_perform?
    assert_equal "This edition is not scheduled for publication", unscheduler.failure_reason
  end

  test "unscheduling a scheduled edition transitions back to submitted and dequeues the schedule job" do
    edition     = create(:scheduled_edition)
    unscheduler = EditionUnscheduler.new(edition)

    ScheduledPublishingWorker.expects(:dequeue).with(edition)
    assert unscheduler.perform!
    assert edition.submitted?
  end

  test "unscheduling a force-scheduled edition transitions back to draft and resets the force_published flag" do
    edition     = create(:scheduled_edition, force_published: true)
    unscheduler = EditionUnscheduler.new(edition)

    ScheduledPublishingWorker.expects(:dequeue).with(edition)
    assert unscheduler.perform!
    assert edition.submitted?
    assert_not edition.force_published?
  end
end
