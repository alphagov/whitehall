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

  test "republishes each child document when the parent is updated via its title" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    Whitehall::PublishingApi.expects(:republish_document_async).with(child_edition.document)

    parent_edition.update!(title: "Renamed")
  end

  test "republishes each child document when the parent's slug is updated directly" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    Whitehall::PublishingApi.expects(:republish_document_async).with(child_edition.document)

    parent_edition.update!(slug_override: "custom-parent-slug")

    assert_equal "custom-parent-slug", parent_edition.slug
    assert_equal "/government/test/custom-parent-slug/#{child_edition.slug}", child_edition.reload.base_path
    assert_equal "draft", parent_edition.state
  end

  test "republishes each child document when the parent's state changes" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(
      :standard_edition,
      configurable_document_type: "test_type",
      state: "draft",
      major_change_published_at: 1.day.ago,
    )
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    Whitehall::PublishingApi.expects(:republish_document_async).with(child_edition.document)

    parent_edition.major_change_published_at = Time.zone.now
    parent_edition.force_publish!
  end

  test "does not republish child documents when the parent is saved without its slug or state changing" do
    test_type = build_configurable_document_type("test_type")
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    create(
      :parent_child_relationship,
      parent_edition: parent_edition,
      child_document: child_edition.document,
    )

    Whitehall::PublishingApi.expects(:republish_document_async).never

    parent_edition.update!(summary: "Updated summary")
  end
end
