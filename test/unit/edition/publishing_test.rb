require "test_helper"

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
    publish(new_draft)

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
    publish(new_draft)

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
    publish(minor_change_edition)

    assert_equal '1.1', minor_change_edition.published_version

    new_draft = minor_change_edition.create_draft(editor)
    new_draft.change_note = 'My new version'
    new_draft.submit!
    publish(new_draft)

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
  test "a draft edition has no published version number" do
    draft_edition = create(:draft_edition)
    assert_nil draft_edition.published_version
  end

  test "incrementing the version number of a first edition sets published version to 1.0" do
    edition = create(:submitted_edition)
    edition.increment_version_number
    assert_equal '1.0', edition.published_version
  end

  test "incrementing the version number on a major change resets the minor version and increments the major version" do
    edition = create(:published_edition, published_major_version: 1, published_minor_version: 2)
    new_draft = edition.create_draft(create(:departmental_editor))
    new_draft.increment_version_number
    assert_equal '2.0', new_draft.published_version
  end

  test "incrementing the version number on a minor change updates the minor version" do
    edition = create(:published_edition)
    new_draft = edition.create_draft(create(:policy_writer))
    new_draft.minor_change = true
    new_draft.increment_version_number
    assert_equal '1.1', new_draft.published_version
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
