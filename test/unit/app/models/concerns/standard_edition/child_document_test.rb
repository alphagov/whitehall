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
end
