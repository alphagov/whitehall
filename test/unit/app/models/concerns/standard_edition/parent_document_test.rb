require "test_helper"

class StandardEdition::ParentDocumentTest < ActiveSupport::TestCase
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
end
