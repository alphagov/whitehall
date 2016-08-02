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

  test "#update_memberships_and_attributes returns false and rolls back changes if the update fails" do
    person = create(:person)
    group = create(:group)
    group_membership = create(:group_membership, group: group, person: person)

    group.stubs(:save!).raises(ActiveRecord::RecordInvalid.new(group))

    refute group.update_memberships_and_attributes({}, [1])
    refute group_membership.destroyed?
  end

  test "#update_memberships_and_attributes populates the errors array if the update fails" do
    person = create(:person)
    group = create(:group)

    refute group.update_memberships_and_attributes({}, [person.id, person.id])

    assert_equal group.errors.count, 1
  end

  test "#update_memberships_and_attributes returns true if memberships and attributes are updated" do
    group = create(:group)
    person = create(:person)

    assert group.update_memberships_and_attributes({}, [person.id])
  end

  test "#update_memberships_and_attributes calls active record to save attributes" do
    group = create(:group)

    group.expects(:save!).once

    group.update_memberships_and_attributes({}, [])
  end

  test "#update_memberships_and_attributes removes existing memberships and rebuilds them" do
    person = create(:person)
    group = create(:group, members: [person])

    group_membership = GroupMembership.first

    group.update_memberships_and_attributes({}, [person.id])

    assert_equal GroupMembership.where(id: group_membership.id), []
    assert_equal group.members.first, person
  end
end
