require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    group = build(:group, name: nil)
    refute group.valid?
  end

  test "should be invalid without an organisation" do
    group = build(:group, organisation: nil)
    refute group.valid?
  end

  test "should be invalid if name already exists for this organisation" do
    organisation = create(:organisation)
    existing_group = create(:group, organisation: organisation, name: "Defence Council")
    group = build(:group, organisation: organisation, name: existing_group.name)
    refute group.valid?
  end

  test "should be valid if name already exists for another organisation" do
    organisation, another_organisation = create(:organisation), create(:organisation)
    existing_group = create(:group, organisation: organisation, name: "Defence Council")
    group = build(:group, organisation: another_organisation, name: existing_group.name)
    assert group.valid?
  end

  test "should generate a slug based on its name" do
    group = create(:group, name: 'My Group Name')
    assert_equal 'my-group-name', group.slug
  end

  test "should not change the slug when the name is changed" do
    group = create(:group, name: 'The Best Group Ever')
    group.update_attributes(name: 'The Worst Group Ever')
    assert_equal 'the-best-group-ever', group.reload.slug
  end

  test "should not include apostrophes in slug" do
    group = create(:group, name: "Bob's committee")
    assert_equal 'bobs-committee', group.slug
  end

  test "should be destroyable when it has no members" do
    group = create(:group, members: [])
    assert group.destroyable?
    assert group.destroy
  end

  test "should not be destroyable when it has members" do
    group = create(:group, members: [create(:person)])
    refute group.destroyable?
    refute group.destroy
  end
end
