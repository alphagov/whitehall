require "test_helper"

class ParentChildRelationshipTest < ActiveSupport::TestCase
  test "should be invalid without a parent edition" do
    relationship = build(:parent_child_relationship, parent_edition: nil)
    assert_not relationship.valid?
  end

  test "should be invalid without a child document" do
    relationship = build(:parent_child_relationship, child_document: nil)
    assert_not relationship.valid?
  end

  test "should be invalid if more than one relationship exists from one parent to one child" do
    existing_relationship = create(:parent_child_relationship)

    relationship = build(
      :parent_child_relationship,
      parent_edition: existing_relationship.parent_edition,
      child_document: existing_relationship.child_document,
    )

    assert_not relationship.valid?
  end

  test "should be valid if one parent edition has two separate child documents" do
    parent_edition = create(:edition)

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

    _existing_relationship = create(
      :parent_child_relationship,
      child_document:,
    )

    relationship = build(
      :parent_child_relationship,
      child_document:,
    )

    assert relationship.valid?
  end

  test "should allow creation" do
    relationship = build(:parent_child_relationship)
    assert_nothing_raised { relationship.save! }
  end

  test "should allow destruction" do
    relationship = create(:parent_child_relationship)
    assert_nothing_raised { relationship.destroy! }
  end

  test "should be invalid if the parent edition does not exist" do
    relationship = build(:parent_child_relationship, parent_edition_id: 9999)
    assert_not relationship.valid?
  end

  test "should be invalid if parent edition is not pre-publication" do
    invalid_states = Edition::POST_PUBLICATION_STATES
    assert_equal invalid_states.count, 4

    invalid_states.each do |state|
      parent_edition = create("#{state}_edition".to_sym) # rubocop:disable Rails/SaveBang

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
      parent_edition = create("#{state}_edition".to_sym) # rubocop:disable Rails/SaveBang

      relationship = build(
        :parent_child_relationship,
        parent_edition:,
      )

      assert relationship.valid?, "expected parent edition in state #{state} to be valid"
    end
  end
end
