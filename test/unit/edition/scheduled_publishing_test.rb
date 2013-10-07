require "test_helper"

class Edition::ScheduledPublishingTest < ActiveSupport::TestCase
  test "draft, submitted or rejected edition is not valid if scheduled_publication date is sooner than the default minimum cache lifetime" do
    editor = build(:departmental_editor)
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

  test "scheduled_publication can be in the past when rejecting" do
    editor = create(:departmental_editor)
    edition = create(:edition, :submitted, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.reject!
      assert edition.rejected?
      assert edition.reload.rejected?
    end
  end

  test "scheduled_publication can be in the past when unpublishing" do
    editor = create(:departmental_editor)
    edition = create(:edition, :published, scheduled_publication: Whitehall.default_cache_max_age.from_now)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 1.minute) do
      assert edition.unpublish!
      assert edition.draft?
      assert edition.reload.draft?
    end
  end

  test "scheduled_publication must be in the future if editing a rejected document" do
    editor = create(:departmental_editor)
    edition = create(:edition, :rejected, scheduled_publication: Whitehall.default_cache_max_age.from_now + 1.minute)
    Timecop.freeze(Whitehall.default_cache_max_age.from_now + 2.minutes) do
      refute edition.valid?
      edition.scheduled_publication = Whitehall.default_cache_max_age.from_now
      assert edition.valid?
    end
  end

  test "is never publishable if submitted with a scheduled_publication date, even if no reason to prevent approval" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    assert_equal "Can't publish this edition immediately as it has a scheduled publication date. Schedule it for publication or remove the scheduled publication date.", edition.reason_to_prevent_publication
  end

  test "is never publishable if scheduled, but the scheduled_publication date has not yet arrived" do
    editor = build(:departmental_editor)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    Timecop.freeze(edition.scheduled_publication - 1.second) do
      assert_equal "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before", edition.reason_to_prevent_publication
    end
  end

  test "is not schedulable if already scheduled" do
    editor = build(:departmental_editor)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    assert_equal "This edition is already scheduled for publication", edition.reason_to_prevent_scheduling_by(editor)
    refute edition.schedulable_by?(editor)
    refute edition.schedulable_by?(editor, force: true)
    assert_equal "This edition is already scheduled for publication", edition.reason_to_prevent_scheduling_by(editor)
  end

  test "is publishable by scheduled publishing robot if scheduled and the scheduled_publication date has passed" do
    editor = build(:scheduled_publishing_robot)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    Timecop.freeze(edition.scheduled_publication) do
      assert_nil edition.reason_to_prevent_publication
    end
  end

  test "publishing a force-scheduled edition does not clear the force_published flag" do
    robot_user = create(:scheduled_publishing_robot)
    edition = create(:scheduled_edition, scheduled_publication: 1.day.from_now, force_published: true)
    Timecop.freeze(edition.scheduled_publication) do
      edition.perform_publish
    end
    assert_equal true, edition.reload.force_published
  end

  test "is not schedulable if the edition is invalid" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now, title: nil)
    refute edition.schedulable_by?(stub)
    assert_equal "This edition is invalid. Edit the edition to fix validation problems", edition.reason_to_prevent_scheduling_by(stub)
  end

  test "is schedulable if submitted with a scheduled_publication date" do
    editor = build(:departmental_editor)
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    assert edition.schedulable_by?(editor)
  end

  test "scheduling marks edition as scheduled" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.schedule_as(create(:departmental_editor))
    assert edition.reload.scheduled?
  end

  test "scheduling fails if not schedulable by user" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition)
    edition.stubs(:schedulable_by?).with(editor, anything).returns(false)
    refute edition.schedule_as(editor)
    refute edition.reload.published?
  end

  test "scheduling adds reason for failure to validation errors" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition)
    edition.stubs(:schedulable_by?).returns(false)
    edition.stubs(:reason_to_prevent_scheduling_by).with(editor, {}).returns('a spurious reason')
    edition.schedule_as(editor)
    assert_equal ['a spurious reason'], edition.errors.full_messages
  end

  test "is unschedulable only if scheduled" do
    author = build(:author)
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
    assert edition.schedule_as(create(:departmental_editor), force: true)
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
