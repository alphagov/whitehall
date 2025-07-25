require "test_helper"

class EditionSchedulerTest < ActiveSupport::TestCase
  test "#perform! with a valid (submitted) schedulable edition transitions the edition and queues a publish job" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)

    assert EditionScheduler.new(edition).perform!
    assert edition.scheduled?

    assert job = ScheduledPublishingWorker.jobs.last
    assert_equal edition.id, job["args"].first
    assert_equal edition.scheduled_publication.to_i, job["at"].to_i
  end

  %w[published draft rejected superseded scheduled].each do |state|
    test "#{state} editions cannot be scheduled" do
      edition = create(:"#{state}_edition", scheduled_publication: 1.day.from_now)
      scheduler = EditionScheduler.new(edition)

      assert_not scheduler.can_perform?
      assert_equal "An edition that is #{state} cannot be scheduled", scheduler.failure_reason
    end
  end

  test "an invalid edition cannot be scheduled" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.title = nil
    scheduler = EditionScheduler.new(edition)

    assert_not scheduler.can_perform?
    assert_equal "This edition is invalid: Title cannot be blank", scheduler.failure_reason
  end

  test "an edition that is invalid in the 'publish' context cannot be scheduled" do
    TaxonValidator.any_instance.unstub(:validate)
    stub_any_publishing_api_call_to_return_not_found
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)

    assert_not edition.has_been_tagged?

    scheduler = EditionScheduler.new(edition)
    assert_not scheduler.can_perform?
    assert_equal "This edition is invalid: You need to add a topic before publishing.", scheduler.failure_reason
  end

  test "an edition cannot be scheduled without a scheduled_publication timestamp" do
    edition = create(:submitted_edition)
    scheduler = EditionScheduler.new(edition)

    assert_not scheduler.can_perform?
    assert_equal "This edition does not have a scheduled publication date set", scheduler.failure_reason
  end

  test "an edition cannot be sheduled if scheduled_publication date is sooner than the default minimum cache lifetime" do
    Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
    edition = create(:submitted_edition, scheduled_publication: Whitehall.default_cache_max_age.from_now - 1.second + 1.minute)
    scheduler = EditionScheduler.new(edition)

    Timecop.freeze(2.minutes.from_now) do
      assert_not scheduler.can_perform?
      assert_match %r{Scheduled publication date must be at least 15 minutes from now}, scheduler.failure_reason
    end
  end
end
