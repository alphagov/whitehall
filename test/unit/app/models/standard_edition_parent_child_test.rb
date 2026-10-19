require "test_helper"

class StandardEditionTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "is invalid if given a parent_edition_id that does not correspond to an existing edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    edition = build(
      :standard_edition,
      parent_edition_id: -1,
      configurable_document_type: "test_type",
      block_content: { body: "FOO" },
    )

    assert_not edition.valid?
    assert_includes edition.errors[:parent_edition_id], "must correspond to an existing StandardEdition"
  end

  test "is invalid if given a parent_edition_id that corresponds to an edition that is not a StandardEdition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    non_standard_edition = create(:edition)

    edition = build(
      :standard_edition,
      parent_edition_id: non_standard_edition.id,
      configurable_document_type: "test_type",
      block_content: { body: "FOO" },
    )

    assert_not edition.valid?
    assert_includes edition.errors[:parent_edition_id], "must correspond to an existing StandardEdition"
  end

  test "creates ParentChildRelationship when given a valid parent_edition_id" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_document = create(:document)

    child_edition = build(
      :standard_edition,
      document: child_document,
      parent_edition_id: parent_edition.id,
      configurable_document_type: "test_type",
      block_content: { body: "FOO" },
    )

    assert_difference("ParentChildRelationship.count", 1) do
      child_edition.save!
    end

    assert_equal parent_edition, child_edition.parent_edition
    assert_equal [child_edition.document], parent_edition.child_documents
  end

  test "is invalid if the parent's type does not allow the child's configurable_document_type" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")

    child_edition = build(
      :standard_edition,
      parent_edition_id: parent_edition.id,
      configurable_document_type: "test_type",
      block_content: { body: "FOO" },
    )

    assert_not child_edition.valid?
    assert_includes child_edition.errors[:parent_edition_id], "must be configured to allow this child document"
  end

  test "is valid if the parent's type explicitly allows the child's configurable_document_type" do
    parent_type = build_configurable_document_type("parent_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "child_type" }] },
    })
    child_type = build_configurable_document_type("child_type")
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type))

    parent_edition = create(:standard_edition, configurable_document_type: "parent_type")

    child_edition = build(
      :standard_edition,
      parent_edition_id: parent_edition.id,
      configurable_document_type: "child_type",
      block_content: { body: "FOO" },
    )

    assert child_edition.valid?
  end

  test "duplicates existing parent child relationships when duplicating a parent edition" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))

    parent_edition = create(
      :standard_edition,
      configurable_document_type: "test_type",
      state: "published",
      major_change_published_at: 1.day.ago,
    )

    create(
      :standard_edition,
      parent_edition_id: parent_edition.id,
      configurable_document_type: "test_type",
    )

    new_parent_edition = parent_edition.create_draft(create(:user))

    assert_equal 1, parent_edition.child_relationships.count, new_parent_edition.child_relationships.count
    assert_equal parent_edition.child_relationships.first.child_document,
                 new_parent_edition.child_relationships.first.child_document
  end

  test "nests the child edition path under the parent edition path" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))

    parent_edition = create(:standard_edition, title: "My Parent")
    child_edition = create(:standard_edition, title: "My Child", parent_edition_id: parent_edition.id)

    assert_equal "/government/test/my-parent", parent_edition.base_path
    assert_equal "/government/test/my-parent/my-child", child_edition.base_path
  end

  test "unrelated child-level edition paths don't conflict with each other" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))

    parent_edition_1 = create(:standard_edition, title: "My First Parent")
    child_edition_1 = create(:standard_edition, title: "My Child", parent_edition_id: parent_edition_1.id)

    parent_edition_2 = create(:standard_edition, title: "My Second Parent")
    child_edition_2 = create(:standard_edition, title: "My Child", parent_edition_id: parent_edition_2.id)

    assert_equal "/government/test/my-first-parent", parent_edition_1.base_path
    assert_equal "/government/test/my-first-parent/my-child", child_edition_1.base_path
    assert_equal "/government/test/my-second-parent", parent_edition_2.base_path
    assert_equal "/government/test/my-second-parent/my-child", child_edition_2.base_path
  end

  test "child-level edition paths conflict with each other if they share the same parent" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", {
      "settings" => { "allowed_child_document_types" => [{ "document_type" => "test_type" }] },
    }))

    parent_edition_1 = create(:standard_edition, title: "My First Parent")
    child_edition_1 = create(:standard_edition, title: "My Child", parent_edition_id: parent_edition_1.id)
    child_edition_2 = create(:standard_edition, title: "My Child", parent_edition_id: parent_edition_1.id)

    assert_equal "/government/test/my-first-parent", parent_edition_1.base_path
    assert_equal "/government/test/my-first-parent/my-child", child_edition_1.base_path
    assert_equal "/government/test/my-first-parent/my-child--2", child_edition_2.base_path
  end
end
