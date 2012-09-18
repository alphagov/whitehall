require "test_helper"

class Edition::PublishingControlsTest < ActiveSupport::TestCase

  test "is approvable by an editor when submitted" do
    edition = create(:submitted_edition)
    assert edition.approvable_by?(create(:departmental_editor))
  end

  test "is never approvable by a writer" do
    writer = create(:policy_writer)
    edition = create(:submitted_edition)
    refute edition.approvable_by?(writer)
    refute edition.approvable_by?(writer, force: true)
    assert_equal "Only departmental editors can publish", edition.reason_to_prevent_approval_by(writer)
  end

  test "is never approvable when already published" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    refute edition.approvable_by?(editor)
    refute edition.approvable_by?(editor, force: true)
    assert_equal "This edition has already been published", edition.reason_to_prevent_approval_by(editor)
  end

  test "is not normally approvable when draft" do
    editor = create(:departmental_editor)
    edition = create(:draft_edition)
    refute edition.approvable_by?(editor)
    assert_equal "Not ready for publication", edition.reason_to_prevent_approval_by(editor)
  end

  test "is force approvable when draft" do
    edition = create(:draft_edition)
    assert edition.approvable_by?(create(:departmental_editor), force: true)
  end

  test "is not normally approvable by the original creator" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    refute edition.approvable_by?(editor)
    assert_equal "You are not the second set of eyes", edition.reason_to_prevent_approval_by(editor)
  end

  test "is force approvable by the original creator" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    assert edition.approvable_by?(editor, force: true)
  end

  test "is never approvable when invalid" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    edition.update_attribute(:title, nil)
    refute edition.approvable_by?(editor, force: true)
    assert_equal "This edition is invalid. Edit the edition to fix validation problems", edition.reason_to_prevent_approval_by(editor)
  end

  test "is never approvable when rejected" do
    editor = create(:departmental_editor)
    edition = create(:rejected_edition)
    refute edition.approvable_by?(editor)
    refute edition.approvable_by?(editor, force: true)
    assert_equal "This edition has been rejected", edition.reason_to_prevent_approval_by(editor)
  end

  test "is never approvable when archived" do
    editor = create(:departmental_editor)
    edition = create(:archived_edition)
    refute edition.approvable_by?(editor)
    refute edition.approvable_by?(editor, force: true)
    assert_equal "This edition has been archived", edition.reason_to_prevent_approval_by(editor)
  end

  test "is never approvable when deleted" do
    editor = create(:departmental_editor)
    edition = create(:deleted_edition)
    refute edition.approvable_by?(editor)
    refute edition.approvable_by?(editor, force: true)
    assert_equal "This edition has been deleted", edition.reason_to_prevent_approval_by(editor)
  end

  test "is not publishable if there is a reason to prevent approval" do
    edition = build(:submitted_edition)
    arbitrary_reason = "Because I said so"
    edition.stubs(:reason_to_prevent_approval_by).returns(arbitrary_reason)
    refute edition.publishable_by?(stub)
    assert_equal arbitrary_reason, edition.reason_to_prevent_publication_by(stub)
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
end

class Edition::PublishingChangeNoteTest < ActiveSupport::TestCase
  test "a draft is valid without change note when first saved even if a published edition already exists" do
    published_edition = create(:published_edition)
    edition = build(:draft_edition, change_note: nil, minor_change: false, document: published_edition.document)
    assert edition.valid?
  end

  test "a draft is invalid without change note once saved if a published edition already exists" do
    published_edition = create(:published_edition)
    edition = create(:draft_edition, change_note: nil, minor_change: false, document: published_edition.document)
    refute edition.valid?
  end

  test "a draft is valid without change note if deleting" do
    published_edition = create(:published_edition)
    edition = create(:draft_edition, change_note: nil, minor_change: false, document: published_edition.document)
    edition.delete!
    assert edition.valid?
  end

  test "is valid without change note if no published edition already exists" do
    edition = create(:draft_edition, change_note: nil, minor_change: false)
    assert edition.valid?
  end

  test "is valid without change note if it is the only published edition that exists" do
    published_edition = create(:published_edition, change_note: nil, minor_change: false)
    assert published_edition.valid?
  end

  test "is valid with minor change when previous published edition exists" do
    published_edition = create(:published_edition)
    edition = build(:draft_edition, change_note: nil, minor_change: true, document: published_edition.document)
    assert edition.valid?
  end

  test "is valid with change note when previous published edition exists" do
    published_edition = create(:published_edition)
    edition = build(:draft_edition, change_note: 'something', minor_change: false, document: published_edition.document)
    assert edition.valid?
  end
end

class Edition::PublishingTest < ActiveSupport::TestCase
  test "publication marks edition as published" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    assert edition.reload.published?
  end

  test "publication records time of publication" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    assert_equal Time.zone.now, edition.reload.published_at
  end

  test "publication records time of first publication if none is provided" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    assert_equal Time.zone.now, edition.reload.first_published_at
  end

  test "publication does not update time of publication if minor change" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: nil, minor_change: true, document: published_edition.document)
    Timecop.travel 1.day.from_now
    edition.publish_as(create(:departmental_editor))
    assert_equal published_edition.published_at, edition.reload.published_at
  end

  test "publication preserves time of first publication if provided" do
    first_published_at = 1.week.ago
    edition = create(:submitted_edition, first_published_at: first_published_at)
    edition.publish_as(create(:departmental_editor))
    assert_equal first_published_at, edition.reload.first_published_at
  end

  test "publication archives previous published versions" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: "change-note", document: published_edition.document)
    edition.publish_as(create(:departmental_editor))
    assert published_edition.reload.archived?
  end

  test "publication archives previous published versions, even if first edition has no change note" do
    first_edition = create(:published_edition, change_note: nil, minor_change: false)
    edition = create(:submitted_edition, change_note: "change-note", document: first_edition.document)
    edition.publish_as(create(:departmental_editor))
    assert first_edition.reload.archived?
  end

  test "publication fails if not publishable by user" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition)
    edition.stubs(:publishable_by?).with(editor, anything).returns(false)
    refute edition.publish_as(editor)
    refute edition.reload.published?
  end

  test "publication adds reason for failure to validation errors" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition)
    edition.stubs(:publishable_by?).returns(false)
    edition.stubs(:reason_to_prevent_publication_by).with(editor, {}).returns('a spurious reason')
    edition.publish_as(editor)
    assert_equal ['a spurious reason'], edition.errors.full_messages
  end

  test "publication raises StaleObjectError if lock version is not current" do
    edition = create(:submitted_edition, title: "old title")

    Edition.find(edition.id).update_attributes(title: "new title")

    assert_raises(ActiveRecord::StaleObjectError) do
      edition.publish_as(create(:departmental_editor))
    end
    refute Edition.find(edition.id).published?
  end

  test "#approve_retrospectively_as should clear the force_published flag, and return true on success" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    assert edition.approve_retrospectively_as(other_editor)
    refute edition.force_published?
  end

  test "#approve_retrospectively_as should return false and set a validation error if document was not force-published" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: false) }

    refute edition.approve_retrospectively_as(other_editor)
    assert edition.errors[:base].include?('This document has not been force-published')
  end

  test "#approve_retrospectively_as should return false and set a validation error if attempted by a writer" do
    editor, writer = create(:departmental_editor), create(:policy_writer)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    refute edition.approve_retrospectively_as(writer)
    assert edition.force_published?
    assert edition.errors[:base].include?('Only departmental editors can retrospectively approve a force-published document')
  end

  test "#approve_retrospectively_as should return false and set a validation error if attempted by the force-publisher" do
    editor = create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    refute edition.approve_retrospectively_as(editor)
    assert edition.force_published?
    assert edition.errors[:base].include?('You are not allowed to retrospectively approve this document, since you force-published it')
  end
end

class Edition::SchedulingTest < ActiveSupport::TestCase
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
