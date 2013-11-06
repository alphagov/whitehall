require 'test_helper'

class EditionArchiverTest < ActiveSupport::TestCase

  test '#perform! with a published edition that has a valid Unpublishing transitinos the edition to an "archived" state' do
    edition = create(:published_edition)
    edition.build_unpublishing(explanation: 'Old policy', unpublishing_reason_id: UnpublishingReason::Archived.id)
    unpublisher = EditionArchiver.new(edition)

    assert unpublisher.perform!
    assert_equal :archived, edition.reload.current_state
    assert_equal 'Old policy', edition.unpublishing.explanation
    assert_equal UnpublishingReason::Archived, edition.unpublishing.unpublishing_reason
    assert_equal '1.0', edition.published_version
  end

  test 'only "published" editions can be archived' do
    (Edition.available_states - [:published]).each do |state|
      edition = create(:"#{state}_edition")
      edition.build_unpublishing(unpublishing_params)
      unpublisher = EditionArchiver.new(edition)

      refute unpublisher.perform!
      assert_equal state, edition.current_state
      assert_equal "An edition that is #{state} cannot be archived", unpublisher.failure_reason
    end
  end

  test 'cannot archive an invalid edition' do
    edition = build(:published_edition, title: nil)
    unpublisher = EditionArchiver.new(edition)

    refute unpublisher.can_perform?
    assert_equal "This edition is invalid: Title can't be blank", unpublisher.failure_reason
  end

  test 'cannot archive a published editions if a newer draft exists' do
    edition = create(:published_edition)
    edition.create_draft(create(:policy_writer))
    unpublisher = EditionArchiver.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'There is already a draft edition of this document. You must remove it before you can archive this edition.',
      unpublisher.failure_reason
  end

  test 'cannot archive without an Unpublishing prepared on the edition' do
    edition = create(:published_edition)
    unpublisher = EditionArchiver.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'The reason for unpublishing must be present', unpublisher.failure_reason
  end

  test 'cannot archive an edition if the Unpublishing is not valid' do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params.merge(redirect: true))

    unpublisher = EditionArchiver.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'Alternative url must be provided to redirect the document', unpublisher.failure_reason
  end

private

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: 'Published by mistake' }
  end
end
