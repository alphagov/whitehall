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
    edition      = create(:published_edition)
    feature_list = create(:feature_list, featurable: edition)
    feature      = create(:feature, feature_list: feature_list, document: edition.document)
    unpublisher  = EditionUnpublisher.new(edition, unpublishing: unpublishing_params)

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

  test "cannot unpublish a parent with a published, withdrawn or scheduled child" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    %i[published_standard_edition withdrawn_standard_edition scheduled_standard_edition].each do |child_factory|
      parent = create(:published_standard_edition, configurable_document_type: "test_type")
      build(:parent_child_relationship, parent_edition: parent, child_document: create(child_factory, configurable_document_type: "test_type").document).save!(validate: false)
      parent.build_unpublishing(unpublishing_params)
      unpublisher = EditionUnpublisher.new(parent)

      assert_not unpublisher.perform!
      assert parent.reload.published?
      assert_equal "You cannot unpublish this #{parent.format_name} while it has published, withdrawn or scheduled child pages.", unpublisher.failure_reason
    end
  end

  test "cannot unpublish a parent with a published child linked only to the parent's newer draft" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent = create(:published_standard_edition, configurable_document_type: "test_type")
    parent_draft = create(:draft_standard_edition, configurable_document_type: "test_type", document: parent.document)
    create(:parent_child_relationship, parent_edition: parent_draft, child_document: create(:published_standard_edition, configurable_document_type: "test_type").document)
    parent.build_unpublishing(unpublishing_params)
    unpublisher = EditionUnpublisher.new(parent)

    assert_not unpublisher.perform!
    assert parent.reload.published?
  end

  test "can unpublish a parent whose children are unpublished" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent = create(:published_standard_edition, configurable_document_type: "test_type")
    build(:parent_child_relationship, parent_edition: parent, child_document: create(:unpublished_standard_edition, configurable_document_type: "test_type").document).save!(validate: false)
    parent.build_unpublishing(unpublishing_params)

    assert EditionUnpublisher.new(parent).perform!
  end

private

  def unpublishing_params
    { unpublishing_reason_id: UnpublishingReason::PublishedInError.id, explanation: "Published by mistake" }
  end
end
