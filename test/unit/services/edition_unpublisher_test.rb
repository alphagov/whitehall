require 'test_helper'

class EditionUnpublisherTest < ActiveSupport::TestCase

  test '#perform! with a published edition that has a valid Unpublishing returns the edition to draft and resets the version numbers' do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params)
    unpublisher = EditionUnpublisher.new(edition)

    assert unpublisher.perform!
    assert_equal :draft, edition.reload.current_state
    assert_equal unpublishing_params[:explanation], edition.unpublishing.explanation
    assert_equal unpublishing_params[:unpublishing_reason_id], edition.unpublishing.unpublishing_reason_id
    assert_nil edition.published_version
  end

  test '#perform! when the edition has been archived transitions the edition to an "archived" state' do
    edition = create(:published_edition)
    edition.build_unpublishing(explanation: 'Old policy', unpublishing_reason_id: UnpublishingReason::Archived.id)
    unpublisher = EditionUnpublisher.new(edition)

    assert unpublisher.perform!
    assert_equal :archived, edition.reload.current_state
    assert_equal 'Old policy', edition.unpublishing.explanation
    assert_equal UnpublishingReason::Archived, edition.unpublishing.unpublishing_reason
    assert_nil edition.published_version
  end

  test '#perform! resets the force published flag' do
    edition = create(:published_edition, force_published: true)
    edition.build_unpublishing(unpublishing_params)
    unpublisher = EditionUnpublisher.new(edition)

    assert unpublisher.perform!
    assert_equal :draft, edition.reload.current_state
    refute edition.force_published?
  end

  test 'only "published" editions can be unpublished' do
    (Edition.available_states - [:published]).each do |state|
      edition = create(:"#{state}_edition")
      unpublisher = EditionUnpublisher.new(edition)

      refute unpublisher.perform!
      assert_equal state, edition.current_state
      assert_equal "An edition that is #{state} cannot be unpublished", unpublisher.failure_reason
    end
  end

  test 'cannot unpublish an invalid edition' do
    edition = build(:published_edition, title: nil)
    unpublisher = EditionUnpublisher.new(edition)

    refute unpublisher.can_perform?
    assert_equal "This edition is invalid: Title can't be blank", unpublisher.failure_reason
  end

  test 'cannot unpublish a published editions if a newer draft exists' do
    edition = create(:published_edition)
    edition.create_draft(create(:policy_writer))
    unpublisher = EditionUnpublisher.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'There is already a draft edition of this document. You must remove it before you can unpublish this edition.',
      unpublisher.failure_reason
  end

  test 'cannot unpublish without an Unpublishing prepared on the edition' do
    edition = create(:published_edition)
    unpublisher = EditionUnpublisher.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'The reason for unpublishing must be present', unpublisher.failure_reason
  end

  test 'cannot unpublish an edition if it does not have a valid Unpublishing' do
    edition = create(:published_edition)
    edition.build_unpublishing(unpublishing_params.merge(redirect: true))

    unpublisher = EditionUnpublisher.new(edition)

    refute unpublisher.can_perform?
    assert_equal 'Alternative url must be provided to redirect the document', unpublisher.failure_reason
  end

private

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: 'Published by mistake' }
  end
end
