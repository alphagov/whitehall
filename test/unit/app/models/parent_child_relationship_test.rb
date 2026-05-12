require "test_helper"

class ParentChildRelationshipTest < ActiveSupport::TestCase
  setup do
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
    other_type = build_configurable_document_type("other_type")
    ConfigurableDocumentType.setup_test_types(parent_type.merge(child_type).merge(other_type))

    @valid_parent_edition = create(:draft_standard_edition, configurable_document_type: "parent_type")
  end

  test "should be invalid without a parent edition" do
    relationship = build(:parent_child_relationship, parent_edition: nil)
    assert_not relationship.valid?
  end

  test "should be invalid without a child document" do
    relationship = build(:parent_child_relationship, child_document: nil)
    assert_not relationship.valid?
  end

  test "should be invalid if more than one relationship exists from one parent to one child" do
    existing_relationship = create(:parent_child_relationship, parent_edition: @valid_parent_edition)

    relationship = build(
      :parent_child_relationship,
      parent_edition: existing_relationship.parent_edition,
      child_document: existing_relationship.child_document,
    )

    assert_not relationship.valid?
  end

  test "should be valid if one parent edition has two separate child documents" do
    parent_edition = @valid_parent_edition

    _existing_relationship = create(
      :parent_child_relationship,
      parent_edition:,
    )

    relationship = build(
      :parent_child_relationship,
      parent_edition:,
    )

    assert relationship.valid?
  end

  test "should be valid if one child document belongs to two parent editions (of the same parent document)" do
    child_document = create(:document)
    parent_edition = create(:draft_standard_edition, configurable_document_type: "parent_type")

    _existing_relationship = create(
      :parent_child_relationship,
      child_document:,
      parent_edition:,
    )

    # Simulate making the parent edition live and then creating a new draft
    parent_edition.update_column(:state, "published")
    parent_draft_edition = create(:draft_standard_edition, configurable_document_type: "parent_type", document: parent_edition.document)

    relationship = build(
      :parent_child_relationship,
      child_document:,
      parent_edition: parent_draft_edition,
    )

    assert relationship.valid?
  end

  test "should be invalid if the parent edition does not exist" do
    relationship = build(:parent_child_relationship, parent_edition_id: 9999)
    assert_not relationship.valid?
  end

  test "should be invalid if parent edition is not pre-publication" do
    invalid_states = Edition::POST_PUBLICATION_STATES
    assert_equal invalid_states.count, 4

    invalid_states.each do |state|
      parent_edition = create("#{state}_standard_edition".to_sym, configurable_document_type: "parent_type")

      relationship = build(
        :parent_child_relationship,
        parent_edition:,
      )

      assert_not relationship.valid?
      assert_includes(
        relationship.errors[:parent_edition],
        "must be in a pre-publication state",
      )
    end
  end

  test "should be valid if parent edition is in a pre-publication state" do
    valid_states = Edition::PRE_PUBLICATION_STATES
    assert_equal valid_states.count, 4

    valid_states.each do |state|
      parent_edition = create("#{state}_standard_edition".to_sym, configurable_document_type: "parent_type")

      relationship = build(
        :parent_child_relationship,
        parent_edition:,
      )

      assert relationship.valid?, "expected parent edition in state #{state} to be valid"
    end
  end

  test "should be invalid if parent edition does not support child editions" do
    parent_edition = create(:draft_standard_edition, configurable_document_type: "other_type")

    relationship = build(
      :parent_child_relationship,
      parent_edition:,
    )

    assert_not relationship.valid?
    assert_includes(
      relationship.errors[:parent_edition],
      "does not support child documents",
    )
  end
end
