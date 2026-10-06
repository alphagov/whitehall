require "test_helper"

class StandardEdition::ChildDocumentTest < ActiveSupport::TestCase
  test "parent_relationship returns ParentChildRelationship object" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    assert child_edition.reload.parent_relationship.is_a?(ParentChildRelationship)
  end

  test "parent_edition returns Edition object" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    assert_equal child_edition.reload.parent_edition, parent_edition
  end

  test "parent_edition_id returns the ID of the parent edition" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    assert_equal child_edition.reload.parent_edition_id, parent_edition.id
  end

  test "parent_edition_must_exist validation works correctly" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    child_edition = build(:standard_edition, configurable_document_type: "test_type")
    child_edition.build_parent_relationship(parent_edition_id: 9999) # Non-existent parent edition

    assert_not child_edition.valid?
    assert_includes child_edition.errors[:parent_edition_id], "must correspond to an existing StandardEdition"
  end

  test "has no unmet publishing prerequisites when it has no parent" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    edition = create(:draft_standard_edition, configurable_document_type: "test_type")

    assert edition.parent_document_published?
    assert_empty edition.unmet_publishing_prerequisites
  end

  test "has no unmet publishing prerequisites when its parent has been published" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition:, child_document: child_edition.document)
    child_edition.reload

    assert child_edition.parent_document_published?
    assert_empty child_edition.unmet_publishing_prerequisites
    child_edition.valid?(:publish)
    assert_empty child_edition.errors[:base]
  end

  test "cannot be published until its parent has been published" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    parent_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition:, child_document: child_edition.document)
    child_edition.reload
    message = "You need to publish the parent test type before you can publish this page."

    assert_not child_edition.parent_document_published?
    assert_equal [message], child_edition.unmet_publishing_prerequisites
    assert_not child_edition.valid?(:publish)
    assert_includes child_edition.errors[:base], message
  end
end
