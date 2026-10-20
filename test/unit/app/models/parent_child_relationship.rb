require "test_helper"

class ParentChildRelationshipTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "is invalid if parent_edition_id is blank" do
    parent_child_relationship = build(
      :parent_child_relationship,
    )

    assert_not parent_child_relationship.valid?
    assert_includes parent_child_relationship.errors[:parent_edition_id], "cannot be blank"
  end
end
