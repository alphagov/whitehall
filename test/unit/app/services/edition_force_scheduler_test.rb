require "test_helper"

class EditionForceSchedulerTest < ActiveSupport::TestCase
  test "#perform! with a draft edition transitions the edition to scheduled with the force_published flag set" do
    edition   = create(:draft_edition, scheduled_publication: 1.day.from_now)
    scheduler = EditionForceScheduler.new(edition)

    ScheduledPublishingWorker.expects(:queue).with(edition)
    assert scheduler.perform!, scheduler.failure_reason
    assert edition.force_published?
    assert edition.scheduled?
  end

  test "#perform! with a submitted edition transitions the edition to scheduled with the force_published flag set" do
    edition   = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    scheduler = EditionForceScheduler.new(edition)

    ScheduledPublishingWorker.expects(:queue).with(edition)
    assert scheduler.perform!, scheduler.failure_reason
    assert edition.force_published?
    assert edition.scheduled?
  end
end
