require "test_helper"

class Edition::ScheduledPublishingTest < ActiveSupport::TestCase
  test "is not valid if scheduled_publication date is in the past" do
    editor = build(:departmental_editor)
    edition = build(:submitted_edition, scheduled_publication: 1.minute.ago)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    refute edition.valid?
    assert edition.errors[:scheduled_publication].include?("date must be in the future")
  end

  test "is publishable if submitted without scheduled_publication date and there is no reason to prevent approval" do
    editor = build(:departmental_editor)
    edition = build(:submitted_edition, scheduled_publication: nil)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    assert edition.publishable_by?(editor)
  end

  test "is never publishable if submitted with a scheduled_publication date, even if no reason to prevent approval" do
    editor = build(:departmental_editor)
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    refute edition.publishable_by?(editor)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition is scheduled for publication on #{1.day.from_now.to_s}, and may not be published before", edition.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable if scheduled, but the scheduled_publication date has not yet arrived" do
    editor = build(:departmental_editor)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    Timecop.freeze(edition.scheduled_publication - 1.second) do
      refute edition.publishable_by?(editor)
      refute edition.publishable_by?(editor, force: true)
      assert_equal "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before", edition.reason_to_prevent_publication_by(editor)
    end
  end

  test "is not schedulable if already scheduled" do
    editor = build(:departmental_editor)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    assert_equal "This edition is already scheduled for publication", edition.reason_to_prevent_scheduling_by(editor)
    refute edition.schedulable_by?(editor)
    refute edition.schedulable_by?(editor, force: true)
  end

  test "is publishable if scheduled, there is no reason to prevent approval and the scheduled_publication date has passed" do
    editor = build(:departmental_editor)
    edition = build(:scheduled_edition, scheduled_publication: 1.day.from_now)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    Timecop.freeze(edition.scheduled_publication) do
      assert_equal nil, edition.reason_to_prevent_publication_by(editor)
      assert edition.publishable_by?(editor)
    end
  end

  test "is not schedulable if there is a reason to prevent approval" do
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    arbitrary_reason = "Because I said so"
    edition.stubs(:reason_to_prevent_approval_by).returns(arbitrary_reason)
    refute edition.schedulable_by?(stub)
    assert_equal arbitrary_reason, edition.reason_to_prevent_scheduling_by(stub)
  end

  test "is schedulable if no reason to prevent approval and submitted with a scheduled_publication date" do
    editor = build(:departmental_editor)
    edition = build(:submitted_edition, scheduled_publication: 1.day.from_now)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
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
end
