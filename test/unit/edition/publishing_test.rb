require "test_helper"

class Edition::PublishingTest < ActiveSupport::TestCase
  test "is publishable by an editor when submitted" do
    edition = create(:submitted_edition)
    assert edition.publishable_by?(create(:departmental_editor))
  end

  test "is never publishable by a writer" do
    writer = create(:policy_writer)
    edition = create(:submitted_edition)
    refute edition.publishable_by?(writer)
    refute edition.publishable_by?(writer, force: true)
    assert_equal "Only departmental editors can publish", edition.reason_to_prevent_publication_by(writer)
  end

  test "is never publishable when already published" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    refute edition.publishable_by?(editor)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition has already been published", edition.reason_to_prevent_publication_by(editor)
  end

  test "is not normally publishable when draft" do
    editor = create(:departmental_editor)
    edition = create(:draft_edition)
    refute edition.publishable_by?(editor)
    assert_equal "Not ready for publication", edition.reason_to_prevent_publication_by(editor)
  end

  test "is force publishable when draft" do
    edition = create(:draft_edition)
    assert edition.publishable_by?(create(:departmental_editor), force: true)
  end

  test "is not normally publishable by the original creator" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    refute edition.publishable_by?(editor)
    assert_equal "You are not the second set of eyes", edition.reason_to_prevent_publication_by(editor)
  end

  test "is force publishable by the original creator" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    assert edition.publishable_by?(editor, force: true)
  end

  test "is never publishable when invalid" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, creator: editor)
    edition.update_attribute(:title, nil)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition is invalid. Edit the edition to fix validation problems", edition.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable when rejected" do
    editor = create(:departmental_editor)
    edition = create(:rejected_edition)
    refute edition.publishable_by?(editor)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition has been rejected", edition.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable when archived" do
    editor = create(:departmental_editor)
    edition = create(:archived_edition)
    refute edition.publishable_by?(editor)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition has been archived", edition.reason_to_prevent_publication_by(editor)
  end

  test "is never publishable when deleted" do
    editor = create(:departmental_editor)
    edition = create(:deleted_edition)
    refute edition.publishable_by?(editor)
    refute edition.publishable_by?(editor, force: true)
    assert_equal "This edition has been deleted", edition.reason_to_prevent_publication_by(editor)
  end

  test "requires change note on publication of new edition if published edition already exists" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, document: published_edition.document)
    assert edition.change_note_required?
  end

  test "does not require change note on publication of new edition if no published edition already exists" do
    edition = create(:submitted_edition)
    refute edition.change_note_required?
  end

  test "is publishable without change note when no previous published edition exists" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition, change_note: nil)
    assert edition.publishable_by?(editor, force: true)
    assert edition.publishable_by?(editor)
  end

  test "is not publishable without change note when previous published edition exists" do
    editor = create(:departmental_editor)
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: nil, document: published_edition.document)
    refute edition.publishable_by?(editor, force: true)
    refute edition.publishable_by?(editor)
    assert_equal "Change note can't be blank", edition.reason_to_prevent_publication_by(editor)
  end

  test "is publishable with change note when previous published edition exists" do
    editor = create(:departmental_editor)
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: "change-note", document: published_edition.document)
    assert edition.publishable_by?(editor, force: true)
    assert edition.publishable_by?(editor)
  end

  test "is publishable as minor change when previous published edition exists" do
    editor = create(:departmental_editor)
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: nil, minor_change: true, document: published_edition.document)
    assert edition.publishable_by?(editor, force: true)
    assert edition.publishable_by?(editor)
  end

  test "is publishable without change note when previous published edition exists if presence of change note is assumed" do
    editor = create(:departmental_editor)
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: nil, document: published_edition.document)
    assert edition.publishable_by?(editor, force: true, assuming_presence_of_change_note: true)
    assert edition.publishable_by?(editor, assuming_presence_of_change_note: true)
  end

  test "is not publishable without change note when previous published edition exists if presence of change note is not assumed" do
    editor = create(:departmental_editor)
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: nil, document: published_edition.document)
    refute edition.publishable_by?(editor, force: true, assuming_presence_of_change_note: false)
    refute edition.publishable_by?(editor, assuming_presence_of_change_note: false)
  end

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

  test "#clear_force_published should clear the force_published flag, and return true on success" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    assert edition.clear_force_published(other_editor)
    refute edition.force_published?
  end

  test "#clear_force_published should return false and set a validation error if document was not force-published" do
    editor, other_editor = create(:departmental_editor), create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: false) }

    refute edition.clear_force_published(other_editor)
    assert edition.errors[:base].include?('This document has not been force-published')
  end

  test "#clear_force_published should return false and set a validation error if attempted by a writer" do
    editor, writer = create(:departmental_editor), create(:policy_writer)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    refute edition.clear_force_published(writer)
    assert edition.force_published?
    assert edition.errors[:base].include?('Only departmental editors can clear the force-published state')
  end

  test "#clear_force_published should return false and set a validation error if attempted by the force-publisher" do
    editor = create(:departmental_editor)
    edition = create(:submitted_policy)
    acting_as(editor) { edition.publish_as(editor, force: true) }

    refute edition.clear_force_published(editor)
    assert edition.force_published?
    assert edition.errors[:base].include?('You are not allowed to clear the force-published state of this document, since you force-published it')
  end
end
