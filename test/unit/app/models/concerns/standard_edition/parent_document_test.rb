require "test_helper"

class StandardEdition::ParentDocumentTest < ActiveSupport::TestCase
  setup do
    test_type = build_configurable_document_type("test_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "child_type",
          },
        ],
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)
  end

  test "is_parent_document? returns false when no child relationships exist" do
    edition = create(:standard_edition)

    assert_not edition.is_parent_document?
  end

  test "is_parent_document? returns true when child relationships exist" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)
    create(:standard_edition, document: child_document)

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document,
    )

    assert parent_edition.is_parent_document?
  end

  test "child_documents returns associated documents" do
    parent_edition = create(:standard_edition)

    child_document_1 = create(:document)
    child_document_2 = create(:document)

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document_1,
    )

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document_2,
    )

    child_documents = parent_edition.child_documents

    assert_equal 2, child_documents.size
    assert_includes child_documents, child_document_1
    assert_includes child_documents, child_document_2
  end

  test "allows_child_documents? determines value from document type settings" do
    parent_type = build_configurable_document_type("parent_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "child_type",
          },
        ],
      },
    })
    child_type = build_configurable_document_type("child_type")
    other_type = build_configurable_document_type("some_other_type")
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type).merge(other_type))

    parent_edition = create(:standard_edition, configurable_document_type: "parent_type")
    child_edition = create(:standard_edition, configurable_document_type: "child_type")
    other_edition = create(:standard_edition, configurable_document_type: "some_other_type")

    assert parent_edition.allows_child_documents?
    assert_not child_edition.allows_child_documents?
    assert_not other_edition.allows_child_documents?
  end

  test "child_editions resolves latest edition for each child document" do
    parent_edition = create(:standard_edition)

    child_document_1 = create(:document)
    child_document_2 = create(:document)

    child_edition_1 = create(:standard_edition, document: child_document_1)
    child_edition_2 = create(:standard_edition, document: child_document_2)

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document_1,
    )

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document_2,
    )

    assert_equal(
      [child_edition_1, child_edition_2].sort_by(&:id),
      parent_edition.child_editions.sort_by(&:id),
    )
  end

  test "child_relationships are destroyed when parent edition is destroyed" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)

    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_document,
    )

    assert_difference("ParentChildRelationship.count", -1) do
      parent_edition.destroy!
    end
  end

  test "process_associations_after_save copies child relationships to new edition" do
    original_parent = create(:standard_edition)
    new_parent = create(:standard_edition)

    child_document = create(:document)

    create(
      :parent_child_relationship,
      parent_edition: original_parent,
      child_document: child_document,
    )

    trait = StandardEdition::ParentDocument::Trait.new(original_parent)

    assert_difference("ParentChildRelationship.count", 1) do
      trait.process_associations_after_save(new_parent)
    end

    copied = ParentChildRelationship.last

    assert_equal new_parent.id, copied.parent_edition_id
    assert_equal child_document.id, copied.child_document_id
  end

  test "process_associations_after_save does not modify existing relationships" do
    original_parent = create(:standard_edition)
    new_parent = create(:standard_edition)

    child_document = create(:document)

    relationship = create(
      :parent_child_relationship,
      parent_edition: original_parent,
      child_document: child_document,
    )

    trait = StandardEdition::ParentDocument::Trait.new(original_parent)

    trait.process_associations_after_save(new_parent)

    assert ParentChildRelationship.exists?(relationship.id)
    assert_equal original_parent.id, relationship.parent_edition_id
  end

  test "process_associations_after_save copies all child relationships" do
    original_parent = create(:standard_edition)
    new_parent = create(:standard_edition)

    3.times do
      create(
        :parent_child_relationship,
        parent_edition: original_parent,
        child_document: create(:document),
      )
    end

    trait = StandardEdition::ParentDocument::Trait.new(original_parent)

    assert_difference("ParentChildRelationship.count", 3) do
      trait.process_associations_after_save(new_parent)
    end

    assert_equal 3, new_parent.child_relationships.count
  end
end
