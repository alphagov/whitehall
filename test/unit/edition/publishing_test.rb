require "test_helper"

class Edition::PublishingControlsTest < ActiveSupport::TestCase

  test "is not publishable when already published" do
    edition = create(:published_edition)
    assert_equal "This edition has already been published", edition.reason_to_prevent_publication
  end

  test "is not normally publishable when draft" do
    edition = create(:draft_edition)
    assert_equal "Not ready for publication", edition.reason_to_prevent_publication
  end

  test "is force publishable when draft" do
    edition = create(:draft_edition)
    assert_nil edition.reason_to_prevent_force_publication
  end

  test "is force publishable when submitted" do
    edition = create(:submitted_edition)
    assert_nil edition.reason_to_prevent_force_publication
  end

  test "is not force publishable when imported" do
    edition = create(:imported_edition)
    assert_equal 'This edition has been imported', edition.reason_to_prevent_force_publication
  end

  test "is never publishable when invalid" do
    edition = build(:submitted_edition, title: nil)
    assert_equal "This edition is invalid. Edit the edition to fix validation problems", edition.reason_to_prevent_publication
  end

  test "is never publishable when rejected" do
    edition = create(:rejected_edition)
    assert_equal "This edition has been rejected", edition.reason_to_prevent_publication
  end

  test "is never publishable when archived" do
    edition = create(:archived_edition)
    assert_equal "This edition has been archived", edition.reason_to_prevent_publication
  end

  test "is never publishable when deleted" do
    edition = create(:draft_edition)
    edition.delete!
    assert_equal "This edition has been deleted", edition.reason_to_prevent_publication
  end

  test "is not publishable if there is a reason to prevent approval" do
    edition = build(:submitted_edition)
    arbitrary_reason = "Because I said so"
    edition.stubs(:reason_to_prevent_publication).returns(arbitrary_reason)
    assert_equal arbitrary_reason, edition.reason_to_prevent_publication
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

  test "is not unpublishable if the edition is not published" do
    non_published_edition = build(:edition, :with_document)
    assert_equal 'This edition has not been published', non_published_edition.reason_to_prevent_unpublication
  end

  test 'is not unpublishable if the document has a draft' do
    edition = create(:published_edition)
    new_draft = edition.create_draft(create(:policy_writer))

    assert_equal 'There is already a draft edition of this document. You must remove it before you can unpublish this edition.',
      edition.reload.reason_to_prevent_unpublication
  end

  test "#perform_unpublish returns true, sets the state back to draft and saves the associated unpublishing" do
    edition = create(:published_edition)
    edition.build_unpublishing(attributes_for(:unpublishing))

    assert edition.perform_unpublish
    assert edition.draft?
    assert edition.unpublishing.persisted?
  end

  test '#perform_unpublish returns false if the edition could not be unpublished, setting the reason why on the edition' do
    edition = create(:draft_edition)
    edition.build_unpublishing(attributes_for(:unpublishing))

    refute edition.perform_unpublish
    assert edition.draft?
    assert edition.unpublishing.new_record?
    assert_equal ['This edition has not been published'], edition.errors[:base]
  end

  test '#perform_unpublish includes validation errrors from the unpublishing on the edition' do
    edition = create(:published_edition)
    edition.build_unpublishing(attributes_for(:unpublishing).merge(redirect: true))

    refute edition.perform_unpublish
    assert edition.published?
    assert edition.unpublishing.new_record?
    assert_equal ['Alternative url must be entered if you want to redirect to it'], edition.errors[:base]
  end

  test "#perform_unpublish on a first edition sets the version number to nil" do
    edition = create(:published_edition)
    edition.build_unpublishing(attributes_for(:unpublishing))

    assert edition.perform_unpublish
    assert_nil edition.reload.published_version
  end

  test "#perform_unpublish on a minor change decrements the minor version" do
    edition = create(:published_edition)
    new_draft = edition.create_draft(create(:policy_writer))
    new_draft.minor_change = true
    new_draft.submit!
    new_draft.perform_publish

    assert_equal '1.1', new_draft.reload.published_version

    new_draft.build_unpublishing(attributes_for(:unpublishing))

    assert new_draft.perform_unpublish
    assert_equal '1.0', new_draft.reload.published_version
  end

  test "#perform_unpublish on a major change decrements the major version" do
    edition = create(:published_edition)
    new_draft = edition.create_draft(create(:policy_writer))
    new_draft.change_note = 'My new version'
    new_draft.submit!
    new_draft.perform_publish

    assert_equal '2.0', new_draft.published_version

    new_draft.build_unpublishing(attributes_for(:unpublishing))
    new_draft.perform_unpublish

    assert_equal '1.0', new_draft.reload.published_version
  end

  test "#perform_unpublish on a major change that has previous minor changes decrements the major version and picks the highest minor version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    minor_change_edition = edition.create_draft(editor)
    minor_change_edition.minor_change = true
    minor_change_edition.submit!
    minor_change_edition.perform_publish

    assert_equal '1.1', minor_change_edition.published_version

    new_draft = minor_change_edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.submit!
    new_draft.perform_publish

    assert_equal '2.0', new_draft.published_version

    new_draft.build_unpublishing(attributes_for(:unpublishing))
    new_draft.perform_unpublish

    assert_equal '1.1', new_draft.reload.published_version
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
    edition.perform_publish
    assert edition.reload.published?
  end

  test "publication records time of major change publication" do
    edition = create(:submitted_edition)
    edition.perform_publish
    assert_equal Time.zone.now, edition.reload.major_change_published_at
  end

  test "publication records time of publication" do
    edition = create(:submitted_edition)
    edition.expects(:make_public_at).with(Time.zone.now)
    edition.perform_publish
  end

  test "publication does not update time of publication if minor change" do
    original_publishing_time = 1.day.ago
    edition = create(:submitted_edition, major_change_published_at: original_publishing_time, change_note: nil, minor_change: true)
    Timecop.travel 1.day.from_now do
      edition.perform_publish
      assert_equal original_publishing_time, edition.major_change_published_at
    end
  end

  test "publication preserves time of first publication if provided" do
    first_published_at = 1.week.ago
    edition = create(:submitted_edition, first_published_at: first_published_at)
    edition.perform_publish
    assert_equal first_published_at, edition.reload.first_published_at
  end

  test "publication archives previous published versions" do
    published_edition = create(:published_edition)
    edition = create(:submitted_edition, change_note: "change-note", document: published_edition.document)
    edition.perform_publish
    assert published_edition.reload.archived?
  end

  test "publication archives previous published versions, even if first edition has no change note" do
    first_edition = create(:published_edition, change_note: nil, minor_change: false)
    edition = create(:submitted_edition, change_note: "change-note", document: first_edition.document)
    edition.perform_publish
    assert first_edition.reload.archived?
  end

  test "publication clears the access_limited flag from a submitted edition if it was set" do
    org = create(:organisation)
    edition = create(:submitted_edition, access_limited: true, organisations: [org])
    assert edition.access_limited
    edition.perform_publish
    refute edition.reload.access_limited?
  end

  test "publication clears the access_limited flag from a scheduled edition if it was set" do
    edition = create(:scheduled_edition, access_limited: true)
    assert edition.access_limited
    Timecop.freeze(edition.scheduled_publication + 1.minute) do
      assert edition.perform_publish, edition.reason_to_prevent_publication
      refute edition.reload.access_limited?
    end
  end

  test "publication adds reason for failure to validation errors" do
    editor = create(:departmental_editor)
    edition = create(:submitted_edition)
    edition.stubs(:reason_to_prevent_publication).returns('a spurious reason')
    edition.perform_publish
    assert_equal ['a spurious reason'], edition.errors.full_messages
  end

  test "publication raises StaleObjectError if lock version is not current" do
    edition = create(:submitted_edition, title: "old title")

    Edition.find(edition.id).update_attributes(title: "new title")

    assert_raise(ActiveRecord::StaleObjectError) do
      edition.perform_publish
    end
    refute Edition.find(edition.id).published?
  end

  test "a draft edition has no published version" do
    draft_edition = create(:draft_edition)
    assert_nil draft_edition.published_version
  end

  test "publication of first edition sets published version to 1.0" do
    edition = create(:submitted_edition)
    edition.perform_publish
    assert_equal '1.0', edition.reload.published_version
  end

  test "publishing a minor change to an edition updates the minor version" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.minor_change = true
    new_draft.submit!
    new_draft.perform_publish
    assert_equal '1.1', new_draft.reload.published_version
  end

  test "publishing a major change to an edition updates the major version and sets minor version to zero" do
    editor = create(:departmental_editor)
    edition = create(:published_edition)
    new_draft = edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.submit!
    new_draft.perform_publish
    assert_equal '2.0', new_draft.reload.published_version
  end

  test "#approve_retrospectively should clear the force_published flag, and return true on success" do
    edition = create(:published_policy, force_published: true)

    assert edition.approve_retrospectively
    refute edition.force_published?
  end

  test "#approve_retrospectively should return false and set a validation error if document was not force-published" do
    edition = create(:published_policy)

    refute edition.approve_retrospectively
    assert edition.errors[:base].include?('This document has not been force-published')
  end
end
