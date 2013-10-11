require "test_helper"

class Edition::ScheduledPublishingTest < ActiveSupport::TestCase
  test "draft, submitted or rejected edition is not valid if scheduled_publication date is sooner than the default minimum cache lifetime" do
    Edition.state_machine.states.each do |state|
      Whitehall.stubs(:default_cache_max_age).returns(15.minutes)
      edition = create(:edition, state.name, scheduled_publication: Whitehall.default_cache_max_age.from_now - 1.second + 1.minute)
      Timecop.freeze(2.minutes.from_now) do
        if [:draft, :submitted, :rejected].include?(state.name)
          refute edition.valid?, "#{state.name} edition should be invalid"
          assert edition.errors[:scheduled_publication].include?("date must be at least 15 minutes from now")
        else
          assert edition.valid?, "#{state.name} edition should be valid, but #{edition.errors.full_messages.inspect}"
        end
      end
    end
  end

  test 'can force scheduled a draft edition' do
    edition = create(:draft_edition, scheduled_publication: 1.day.from_now)
    assert edition.perform_force_schedule
  end

  test 'can force schedule a submitted edition' do
    edition = create(:draft_edition, scheduled_publication: 1.day.from_now)
    assert edition.perform_force_schedule
  end

  test "scheduled_publication can be in the past when rejecting" do
    edition = create(:edition, :submitted, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.reject!
      assert edition.rejected?
      assert edition.reload.rejected?
    end
  end

  test "scheduled_publication can be in the past when unpublishing" do
    edition = create(:edition, :published, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.unpublish!
      assert edition.draft?
      assert edition.reload.draft?
    end
  end

  test "scheduled_publication must be in the future if editing a rejected document" do
    edition = create(:edition, :rejected, scheduled_publication: Whitehall.default_cache_max_age.from_now + 1.minute)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 2.minutes) do
      refute edition.valid?
      edition.scheduled_publication = Whitehall.default_cache_max_age.from_now
      assert edition.valid?
    end
  end

  test "is never publishable if submitted with a scheduled_publication date, even if no reason to prevent approval" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    publisher = EditionPublisher.new(edition)
    refute publisher.can_perform?
    expected_reason = expected_reason = "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before"
    assert_equal expected_reason, publisher.failure_reason
  end

  test "is never publishable if scheduled, but the scheduled_publication date has not yet arrived" do
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    Timecop.freeze(edition.scheduled_publication - 1.second) do
      publisher = EditionPublisher.new(edition)
      refute publisher.can_perform?
      expected_reason = "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before"
      assert_equal expected_reason, publisher.failure_reason
    end
  end

  test "is not schedulable if already scheduled" do
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    assert_equal "This edition is already scheduled for publication", edition.reason_to_prevent_scheduling
  end

  test "is publishable if scheduled and the scheduled_publication date has passed" do
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    Timecop.freeze(edition.scheduled_publication) do
      assert EditionPublisher.new(edition).can_perform?
    end
  end

  test "publishing a force-scheduled edition does not clear the force_published flag" do
    edition = create(:scheduled_edition, scheduled_publication: 1.day.from_now, force_published: true)
    Timecop.freeze(edition.scheduled_publication) do
      EditionPublisher.new(edition).perform!
    end
    assert_equal true, edition.reload.force_published
  end

  test "is not schedulable if the edition is invalid" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now, title: nil)
    assert_equal "This edition is invalid. Edit the edition to fix validation problems", edition.reason_to_prevent_scheduling
  end

  test "is schedulable if submitted with a scheduled_publication date" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    assert_nil edition.reason_to_prevent_scheduling
  end

  test "scheduling returns true and marks edition as scheduled" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    assert edition.perform_schedule
    assert edition.reload.scheduled?
  end

  test "force scheduling returns true, marks edition as scheduled and sets forced flag" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    assert edition.perform_force_schedule
    assert edition.reload.scheduled?
    assert edition.force_published
  end

  test "scheduling returns false and adds reason for failure if can't be scheduled" do
    edition = build(:imported_edition)
    refute edition.perform_schedule
    assert_equal ['This edition has been imported'], edition.errors.full_messages
  end

  test "is unschedulable only if scheduled" do
    Edition.state_machine.states.each do |state|
      edition = build(:edition, state.name)
      if state.name == :scheduled
        assert_equal nil, edition.reason_to_prevent_unscheduling
      else
        assert_equal "This edition is not scheduled for publication", edition.reason_to_prevent_unscheduling
      end
    end
  end

  test "unscheduling changes state to submitted, clears force publish flag and returns true on success" do
    author = build(:author)
    edition = build(:edition, :scheduled, force_published: true)
    assert edition.unschedule_as(author)
    assert_equal "submitted", edition.state
    assert_equal false, edition.force_published
  end

  test "can find editions due for publication" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    already_published = create(:edition, :published, scheduled_publication: 1.day.from_now)
    Timecop.freeze 1.day.from_now do
      assert_equal [due_in_one_day], Edition.due_for_publication
    end
    Timecop.freeze 2.days.from_now do
      assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication
    end
  end

  test "can find editions due for publication within a certain time span" do
    due_in_one_day = create(:edition, :scheduled, scheduled_publication: 1.day.from_now)
    due_in_two_days = create(:edition, :scheduled, scheduled_publication: 2.days.from_now)
    assert_equal [due_in_one_day], Edition.due_for_publication(1.day)
    assert_equal [due_in_one_day, due_in_two_days], Edition.due_for_publication(2.days)
  end

  test ".scheduled_for_publication_as returns edition if edition is scheduled" do
    edition = create(:draft_publication, scheduled_publication: 1.day.from_now)
    assert edition.perform_force_schedule
    assert_equal edition, Publication.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if edition is not scheduled" do
    edition = create(:draft_publication, scheduled_publication: 1.day.from_now)
    assert_nil Edition.scheduled_for_publication_as(edition.document.to_param)
  end

  test ".scheduled_for_publication_as returns nil if document is unknown" do
    assert_nil Edition.scheduled_for_publication_as('unknown')
  end
end
