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

  test "has_published_or_scheduled_children? is true only when a child has a published or scheduled edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")

    {
      draft_standard_edition: false,
      withdrawn_standard_edition: false,
      unpublished_standard_edition: false,
      published_standard_edition: true,
      scheduled_standard_edition: true,
    }.each do |factory, expected|
      child_relationship = build(:parent_child_relationship, parent_edition:, child_document: create(factory, configurable_document_type: "test_type").document)
      child_relationship.save!(validate: false)

      assert_equal expected, parent_edition.reload.has_published_or_scheduled_children?, "child #{factory}"

      child_relationship.destroy!
    end
  end

  test "has_published_or_scheduled_children? is true when a published child has a newer draft" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    child_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    create(:draft_standard_edition, configurable_document_type: "test_type", document: child_edition.document)
    build(:parent_child_relationship, parent_edition:, child_document: child_edition.document).save!(validate: false)

    assert parent_edition.reload.has_published_or_scheduled_children?
  end

  test "has_publicly_visible_or_scheduled_children? is true only when a child has a published, withdrawn or scheduled edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")

    {
      draft_standard_edition: false,
      unpublished_standard_edition: false,
      published_standard_edition: true,
      withdrawn_standard_edition: true,
      scheduled_standard_edition: true,
    }.each do |factory, expected|
      child_relationship = build(:parent_child_relationship, parent_edition:, child_document: create(factory, configurable_document_type: "test_type").document)
      child_relationship.save!(validate: false)

      assert_equal expected, parent_edition.reload.has_publicly_visible_or_scheduled_children?, "child #{factory}"

      child_relationship.destroy!
    end
  end

  test "has_publicly_visible_or_scheduled_children? is true when the child is only linked to a newer draft of the parent" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    parent_draft = create(:draft_standard_edition, configurable_document_type: "test_type", document: parent_edition.document)
    child_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition: parent_draft, child_document: child_edition.document)

    assert parent_edition.reload.has_publicly_visible_or_scheduled_children?
  end
end
