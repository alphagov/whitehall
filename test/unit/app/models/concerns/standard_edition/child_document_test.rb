require "test_helper"

class StandardEdition::ChildDocumentTest < ActiveSupport::TestCase
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

  test "is_child_document? returns false when no relationship exists" do
    edition = create(:standard_edition)
    assert_not edition.is_child_document?
  end

  test "is_child_document? returns true when parent relationship exists" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)
    child_edition = create(:standard_edition, document: child_document)

    create(
      :parent_child_relationship,
      parent_edition:,
      child_document:,
    )

    assert child_edition.is_child_document?
  end

  test "parent_edition returns the correct parent edition" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)
    child_edition = create(:standard_edition, document: child_document)

    create(
      :parent_child_relationship,
      parent_edition:,
      child_document:,
    )

    assert_equal parent_edition, child_edition.parent_edition
  end

  test "parent_relationship resolves via document_id not edition_id" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)
    child_edition_1 = create(:published_standard_edition, document: child_document)
    child_edition_2 = create(:draft_standard_edition, document: child_document)

    create(
      :parent_child_relationship,
      parent_edition:,
      child_document:,
    )

    # Same document, different editions should still resolve same relationship
    assert_equal child_edition_1.parent_relationship,
                 child_edition_2.parent_relationship
  end

  test "parent_relationship is nil when no relationship exists" do
    document = create(:document)
    edition = create(:standard_edition, document:)

    assert_nil edition.parent_relationship
    assert_nil edition.parent_edition
  end

  test "base_path is determined by the parent edition" do
    parent_edition = create(:standard_edition)
    child_document = create(:document)
    child_edition = create(:standard_edition, document: child_document, slug_override: "foo")

    create(
      :parent_child_relationship,
      parent_edition:,
      child_document:,
    )

    assert_equal "#{parent_edition.base_path}/foo", child_edition.base_path
  end
end
