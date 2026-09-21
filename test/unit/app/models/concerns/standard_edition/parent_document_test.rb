require "test_helper"

class StandardEdition::ParentDocumentTest < ActiveSupport::TestCase
  test "child_relationships returns array of ParentChildRelationship objects" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    assert parent_edition.reload.child_relationships.count == 1
    assert(parent_edition.reload.child_relationships.all? { |relationship| relationship.is_a?(ParentChildRelationship) })
  end

  test "child_documents returns array of Document objects" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    assert_equal parent_edition.reload.child_documents, [child_edition.document]
  end
end
