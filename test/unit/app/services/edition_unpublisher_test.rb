require "test_helper"

class EditionUnpublisherTest < ActiveSupport::TestCase
  test "#perform! with a published edition sets the edition state to unpublished, resets the version numbers and saves the unpublishing details" do
    edition = create(:published_edition)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.perform!
    assert_equal :unpublished, edition.reload.current_state
    assert_equal unpublishing_params[:explanation], edition.unpublishing.explanation
    assert_equal unpublishing_params[:unpublishing_reason_id], edition.unpublishing.unpublishing_reason_id
    assert_nil edition.published_version
  end

  test "#perform! with an unpublished edition saves the unpublishing details" do
    edition = create(:unpublished_edition)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.perform!
    assert_equal :unpublished, edition.reload.current_state
    assert_equal unpublishing_params[:explanation], edition.unpublishing.explanation
    assert_equal unpublishing_params[:unpublishing_reason_id], edition.unpublishing.unpublishing_reason_id
    assert_nil edition.published_version
  end

  test "#perform! resets the force published flag" do
    edition = create(:published_edition, force_published: true)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.perform!
    assert_equal :unpublished, edition.reload.current_state
    assert_not edition.force_published?
  end

  test "#perform! ends any featurings associated with the document" do
    edition     = create(:published_edition)
    feature     = create(:feature, document: edition.document)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.perform!
    assert_equal Time.zone.now, feature.reload.ended_at
  end

  test '"published" editions can be unpublished' do
    edition = create(:published_edition)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.perform!
  end

  test "other edition states cannot be unpublished" do
    (Edition.available_states - %i[published unpublished]).each do |state|
      edition = create(:edition, state:, first_published_at: 1.hour.ago)
      unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

      assert_not unpublisher.perform!
      assert_equal state, edition.current_state
      assert_equal "An edition that is #{state} cannot be unpublished", unpublisher.failure_reason
    end
  end

  test "even invalid editions can be unpublished" do
    edition = create(:published_edition)
    edition.summary = nil
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

    assert unpublisher.can_perform?
    assert unpublisher.perform!
    assert edition.reload.unpublished?
  end

  test "cannot unpublish without an unpublishing details" do
    edition = create(:published_edition)
    unpublisher = EditionUnpublisher.new(edition)

    assert_not unpublisher.can_perform?
    assert_equal "The reason for unpublishing must be present", unpublisher.failure_reason
  end

  test "cannot unpublish an edition if the Unpublishing is not valid" do
    edition = create(:published_edition)
    unpublisher = EditionUnpublisher.new(edition, unpublishing: unpublishing_params.merge(redirect: true))

    assert_not unpublisher.can_perform?
    assert_equal "Alternative url must be provided to redirect the document", unpublisher.failure_reason
  end

private

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: "Published by mistake" }
  end
end
