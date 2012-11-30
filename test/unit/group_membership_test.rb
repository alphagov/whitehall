require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  test "should be invalid when person is already a member of the group" do
    group, person = create(:group), create(:person)
    existing_group_membership = create(:group_membership, group: group, person: person)
    group_membership = build(:group_membership, group: group, person: person)
    refute group_membership.valid?
  end
end
