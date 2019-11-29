require "test_helper"

class SpecialRepresentativeRoleTest < ActiveSupport::TestCase
  test "should not be a permanent secretary" do
    role = build(:special_representative_role)
    assert_not role.permanent_secretary?
  end

  test "should not be a cabinet member" do
    role = build(:special_representative_role)
    assert_not role.cabinet_member?
  end

  test "should not be a chief of the defence staff" do
    role = build(:special_representative_role)
    assert_not role.chief_of_the_defence_staff?
  end
end
