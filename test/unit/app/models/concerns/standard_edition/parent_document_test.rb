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

    child_document_1 = create(:standard_edition).document
    child_document_2 = create(:standard_edition).document

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

  test "new_child_documents returns only the child documents that don't have a live edition" do
    parent_edition = create(:standard_edition)

    child_document_1 = create(:published_standard_edition).document
    child_document_2 = create(:draft_standard_edition).document
    relationships = [
      build(
        :parent_child_relationship,
        parent_edition: parent_edition,
        child_document: child_document_1,
      ),
      build(
        :parent_child_relationship,
        parent_edition: parent_edition,
        child_document: child_document_2,
      ),
    ]
    relationships.each { |relationship| relationship.save!(validate: false) }

    assert_equal [child_document_2], parent_edition.new_child_documents
  end

  test "deleting a non-live child edition removes it from the parent edition's child documents" do
    parent_edition = create(:standard_edition)

    child_edition = create(:draft_standard_edition)
    build(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    ).save!(validate: false)

    assert_includes parent_edition.child_documents, child_edition.document

    child_edition.update!(state: "deleted")

    assert_not_includes parent_edition.child_documents, child_edition.document
  end

  test "unable to delete parent edition if it contains any new child documents" do
    parent_edition = create(:standard_edition)

    parent_edition.stubs(:new_child_documents).returns([create(:standard_edition).document])

    error = assert_raises(StandardEdition::ParentDocument::UnableToDelete) do
      parent_edition.update!(state: "deleted")
    end

    assert_equal "This document cannot be deleted while it has child documents that have never been published. Delete the draft child documents first.", error.message
  end

  test "able to unpublish parent edition if all of its children are already unpublished" do
    parent_edition = create(:standard_edition)

    child_edition = create(:unpublished_standard_edition)
    build(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    ).save!(validate: false)

    assert_nothing_raised do
      parent_edition.update!(state: "unpublished")
    end
  end

  test "able to withdraw parent edition if all of its children are already unpublished or withdrawn" do
    parent_edition = create(:standard_edition)
    child_edition_1 = create(:unpublished_standard_edition)
    child_edition_2 = create(:withdrawn_standard_edition)
    [child_edition_1, child_edition_2].each do |child_edition|
      build(
        :parent_child_relationship,
        parent_edition: parent_edition,
        child_document: child_edition.document,
      ).save!(validate: false)
    end

    assert_nothing_raised do
      parent_edition.update!(state: "withdrawn")
    end
  end

  test "unable to unpublish parent edition if it contains any published child documents" do
    parent_edition = create(:standard_edition)

    child_edition = create(:published_standard_edition)
    build(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    ).save!(validate: false)

    error = assert_raises(StandardEdition::ParentDocument::UnableToUnpublish) do
      parent_edition.update!(state: "unpublished")
    end

    assert_equal "This document cannot be unpublished while it has child documents that are published or withdrawn. Unpublish the child documents first.", error.message
  end

  test "unable to unpublish parent edition if it contains any withdrawn child documents" do
    parent_edition = create(:standard_edition)

    child_edition = create(:withdrawn_standard_edition)
    build(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    ).save!(validate: false)

    error = assert_raises(StandardEdition::ParentDocument::UnableToUnpublish) do
      parent_edition.update!(state: "unpublished")
    end

    assert_equal "This document cannot be unpublished while it has child documents that are published or withdrawn. Unpublish the child documents first.", error.message
  end

  test "unable to withdraw parent edition if it contains any published child documents" do
    parent_edition = create(:standard_edition)

    child_edition = create(:published_standard_edition)
    build(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    ).save!(validate: false)

    error = assert_raises(StandardEdition::ParentDocument::UnableToWithdraw) do
      parent_edition.update!(state: "withdrawn")
    end

    assert_equal "This document cannot be withdrawn while it has child documents that are published. Withdraw the child documents first.", error.message
  end
end
