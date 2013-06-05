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

  test "is not force approvable when imported" do
    edition = create(:imported_edition)
    refute edition.approvable_by?(create(:departmental_editor), force: true)
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
    edition = create(:draft_edition)
    edition.delete!
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

  test "is publishable by departmental editor if there is a no reason to prevent approval" do
    edition = build(:submitted_edition)
    edition.stubs(:reason_to_prevent_approval_by).returns(nil)
    assert edition.publishable_by?(build(:departmental_editor))
  end
end

class Edition::UnpublishingControlsTest < ActiveSupport::TestCase

  test ".unpublished_as returns the unpublishing if the edition has been unpublished" do
    publication = create(:unpublished_publication)
    unpublishing = publication.unpublishing
    assert_equal unpublishing, Publication.unpublished_as(publication.document.to_param)
  end

  test ".unpublished_as returns nil if the edition does not have an unpublishing" do
    publication = create(:draft_publication)
    assert_nil Publication.unpublished_as(publication.document.to_param)
  end

  test "is unpublishable if the edition is published and the user is a GDS editor" do
    edition = build(:published_edition, :with_document)
    gds_editor = build(:gds_editor)
    assert edition.unpublishable_by?(gds_editor)
  end

  test "is not unpublishable if the edition is not published" do
    non_published_edition = build(:edition, :with_document)
    gds_editor = build(:gds_editor)
    refute non_published_edition.unpublishable_by?(gds_editor)
  end

  test "is not unpublishable if the user is not a GDS editor" do
    edition = build(:published_edition, :with_document)
    departmental_editor = build(:departmental_editor)
    refute edition.unpublishable_by?(departmental_editor)
  end

  test 'is not unpublishable if the document has a draft' do
    edition = build(:published_edition, :with_document)
    draft_edition = build(:draft_edition)
    edition.stubs(:other_draft_editions).returns([draft_edition])
    gds_editor = build(:gds_editor)

    refute edition.unpublishable_by?(gds_editor)
  end

  test "sets the state back to draft if the edition is unpublishable by the user" do
    user = build(:user)
    edition = build(:published_edition, :with_document)
    edition.stubs(:unpublishable_by?).with(user).returns(true)
    edition.unpublish_as(user)
    assert edition.draft?
  end

  test "adds an editorial remark stating that this edition has been set back to draft if the edition is unpublishable by the user" do
    user = build(:user)
    edition = build(:published_edition, :with_document)
    edition.stubs(:unpublishable_by?).with(user).returns(true)

    edition.unpublish_as(user)

    assert_equal "Reset to draft", edition.editorial_remarks.last.body
    assert_equal user, edition.editorial_remarks.last.author
  end

  test "returns true if the edition is unpublishable by the user" do
    user = build(:user)
    edition = build(:published_edition, :with_document)
    edition.stubs(:unpublishable_by?).with(user).returns(true)
    assert edition.unpublish_as(user)
  end

  test "does not set the state back to draft if the edition is not unpublishable by the user" do
    user = build(:user)
    edition = build(:published_edition, :with_document)
    edition.stubs(:unpublishable_by?).with(user).returns(false)
    edition.unpublish_as(user)
    refute edition.draft?
  end

  test "returns false if the edition is not unpublishable by the user" do
    user = build(:user)
    edition = build(:published_edition, :with_document)
    edition.stubs(:unpublishable_by?).with(user).returns(false)
    refute edition.unpublish_as(user)
  end

  test "adds a suitable error message if the edition is not published" do
    edition = build(:edition, :with_document)
    edition.unpublish_as(build(:user))
    assert edition.errors[:base].include?("This edition has not been published")
  end

  test "adds a suitable error message if the user is not a GDS editor" do
    non_gds_editor = build(:user)
    edition = build(:edition, :with_document)
    edition.unpublish_as(non_gds_editor)
    assert edition.errors[:base].include?("Only GDS editors can unpublish")
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

  test "publication records time of major change publication" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    assert_equal Time.zone.now, edition.reload.major_change_published_at
  end

  test "publication records time of publication" do
    edition = create(:submitted_edition)
    edition.expects(:make_public_at).with(Time.zone.now)
    edition.publish_as(create(:departmental_editor))
  end

  test "publication does not update time of publication if minor change" do
    original_publishing_time = 1.day.ago
    edition = create(:submitted_edition, major_change_published_at: original_publishing_time, change_note: nil, minor_change: true)
    Timecop.travel 1.day.from_now do
      edition.publish_as(create(:departmental_editor))
      assert_equal original_publishing_time, edition.major_change_published_at
    end
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

  test "publication clears the access_limited flag from a submitted edition if it was set" do
    org = create(:organisation)
    edition = create(:submitted_edition, access_limited: true, organisations: [org])
    assert edition.access_limited
    edition.publish_as(create(:departmental_editor, organisation: org))
    refute edition.reload.access_limited?
  end

  test "publication clears the access_limited flag from a scheduled edition if it was set" do
    robot = create(:scheduled_publishing_robot)
    edition = create(:scheduled_edition, access_limited: true)
    assert edition.access_limited
    Timecop.freeze(edition.scheduled_publication + 1.minute) do
      assert edition.publish_as(robot), edition.reason_to_prevent_publication_by(robot)
      refute edition.reload.access_limited?
    end
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

  test "a draft edition has no published version" do
    draft_edition = create(:draft_edition)
    assert_nil draft_edition.published_version
  end

  test "publication of first edition sets published version to 1.0" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    assert_equal '1.0', edition.reload.published_version
  end

  test "publishing a minor change to an edition updates the minor version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.minor_change = true
    new_draft.publish_as(editor, force: true)
    assert_equal '1.1', new_draft.reload.published_version
  end

  test "publishing a major change to an edition updates the major version and sets minor version to zero" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.publish_as(editor, force: true)
    assert_equal '2.0', new_draft.reload.published_version
  end

  test "unpublishing first edition sets published version to nil" do
    edition = create(:submitted_edition)
    edition.publish_as(create(:departmental_editor))
    edition.unpublish_as(create(:gds_editor))
    assert_nil edition.reload.published_version
  end

  test "unpublishing a minor change to an edition decrements the minor version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.minor_change = true
    new_draft.publish_as(editor, force: true)
    new_draft.unpublish_as(create(:gds_editor))
    assert_equal '1.0', new_draft.reload.published_version
  end

  test "unpublishing a major change to an edition decrements the major version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.publish_as(editor, force: true)
    new_draft.unpublish_as(create(:gds_editor))
    assert_equal '1.0', new_draft.reload.published_version
  end

  test "unpublishing a major change to an edition that has previous minor changes decrements the major version and picks the highest minor version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    minor_change_edition = edition.create_draft(editor)
    minor_change_edition.minor_change = true
    minor_change_edition.publish_as(editor, force: true)
    new_draft = minor_change_edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.publish_as(editor, force: true)
    new_draft.unpublish_as(create(:gds_editor))
    assert_equal '1.1', new_draft.reload.published_version
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
