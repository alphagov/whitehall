require "test_helper"

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
  test '#build_unpublishing builds an unpublishing for the edition with the slug and type set' do
    edition = create(:published_edition)
    params  = {
      unpublishing_reason_id: UnpublishingReason::PublishedInError.id,
      explanation: 'This document was published by mistake'
    }

    edition.build_unpublishing(params)

    assert unpublishing = edition.unpublishing
    assert unpublishing.new_record?
    assert unpublishing.valid?
    assert_equal edition.slug, unpublishing.slug
    assert_equal edition.type, unpublishing.document_type
    assert_equal UnpublishingReason::PublishedInError, unpublishing.unpublishing_reason
    assert_equal params[:explanation], unpublishing.explanation
  end

  test ".unpublished_as returns the unpublishing if the edition has been unpublished" do
    publication = create(:unpublished_publication)
    unpublishing = publication.unpublishing
    assert_equal unpublishing, Publication.unpublished_as(publication.document.to_param)
  end

  test ".unpublished_as returns nil if the edition does not have an unpublishing" do
    publication = create(:draft_publication)
    assert_nil Publication.unpublished_as(publication.document.to_param)
  end

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

  test '#reset_version_numbers on a first edition resets the version numbers back to nil' do
    edition = create(:published_edition)
    edition.reset_version_numbers

    assert_nil edition.published_version
  end

  test '#reset_version_numbers on a re-editioned edition resets the version numbers back to that of the previous edition' do
    previous_edition = create(:published_edition, published_major_version: 2, published_minor_version: 4)
    new_edition = previous_edition.create_draft(create(:policy_writer))
    new_edition.minor_change = true
    force_publish(new_edition)

    assert_equal '2.5', new_edition.published_version

    new_edition.reset_version_numbers
    assert_equal '2.4', new_edition.published_version
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
