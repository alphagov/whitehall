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

  test "validates parent_relationship is valid" do
    test_type = build_configurable_document_type("test_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "test_type",
          },
        ],
      },
    })

    ConfigurableDocumentType.setup_test_types(test_type)

    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition.build_parent_relationship(child_document: child_edition.document)

    assert_not child_edition.valid?
    assert_includes child_edition.errors[:parent_edition_id], "cannot be blank"
  end

  test "has no unmet publishing prerequisites when it has no parent" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    edition = create(:draft_standard_edition, configurable_document_type: "test_type")

    assert edition.parent_publication_requirement_met?
    assert_empty edition.unmet_publishing_prerequisites
  end

  test "has no unmet publishing prerequisites when its parent has been published" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    parent_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition:, child_document: child_edition.document)

    parent_edition.major_change_published_at = Time.zone.now
    parent_edition.force_publish!

    child_edition.reload

    assert child_edition.parent_publication_requirement_met?
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

    assert_not child_edition.parent_publication_requirement_met?
    assert_equal [message], child_edition.unmet_publishing_prerequisites
    assert_not child_edition.valid?(:publish)
    assert_includes child_edition.errors[:base], message
  end

  test "cannot be published if its parent is in a pre-published state" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))

    Edition::PRE_PUBLICATION_STATES.each do |state|
      parent_edition = create("#{state}_standard_edition".to_sym, configurable_document_type: "test_type")
      child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
      create(:parent_child_relationship, parent_edition:, child_document: child_edition.document)
      child_edition.reload

      assert_not child_edition.parent_publication_requirement_met?
      assert_not child_edition.valid?(:publish)
      assert_includes child_edition.errors[:base], "You need to publish the parent test type before you can publish this page."
    end
  end

  test "cannot be published if its parent has been previously published but subsequently re-editioned, and the child is associated only with the draft parent" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:published_standard_edition, configurable_document_type: "test_type")
    parent_second_edition = parent_edition.reload.create_draft(create(:writer))
    child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition: parent_second_edition, child_document: child_edition.document)
    child_edition.reload

    assert_not child_edition.parent_publication_requirement_met?
    assert_not child_edition.valid?(:publish)
    assert_includes child_edition.errors[:base], "You need to publish the parent test type before you can publish this page."
  end

  test "can be published if its parent was in draft when it was created but has since been published and reditioned" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    parent_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    child_edition = create(:draft_standard_edition, configurable_document_type: "test_type")
    create(:parent_child_relationship, parent_edition:, child_document: child_edition.document)
    child_edition.reload

    parent_edition.major_change_published_at = Time.zone.now
    parent_edition.force_publish!

    parent_edition.reload.create_draft(create(:writer))

    assert child_edition.parent_publication_requirement_met?
    assert_empty child_edition.unmet_publishing_prerequisites
    child_edition.valid?(:publish)
    assert_empty child_edition.errors[:base]
  end

  test "validates that the parent edition is in a pre-publication state on create" do
    test_type = build_configurable_document_type("test_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "test_type",
          },
        ],
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")

    parent_edition.major_change_published_at = Time.zone.now
    parent_edition.force_publish!

    child_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition.build_parent_relationship(parent_edition: parent_edition, child_document: child_edition.document)

    assert_not child_edition.parent_relationship.valid?
    assert_includes child_edition.parent_relationship.errors[:parent_edition_id], "must be in a draft state in order to create a child page"

    assert_not child_edition.valid?
    assert_includes child_edition.errors[:parent_edition_id], "must be in a draft state in order to create a child page"
  end

  test "can edit and save existing child edition if parent has been published" do
    test_type = build_configurable_document_type("test_type", {
      "settings" => {
        "allowed_child_document_types" => [
          {
            "document_type" => "test_type",
          },
        ],
      },
    })
    ConfigurableDocumentType.setup_test_types(test_type)

    parent_edition = create(:standard_edition, configurable_document_type: "test_type")
    child_edition = create(:standard_edition, configurable_document_type: "test_type", parent_edition_id: parent_edition.id)

    parent_edition.major_change_published_at = Time.zone.now
    parent_edition.force_publish!

    assert child_edition.valid?
  end
end
