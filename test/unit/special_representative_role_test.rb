require "test_helper"

class SpecialRepresentativeRoleTest < ActiveSupport::TestCase
  test "should not be a permanent secretary" do
    role = build(:special_representative_role)
    refute role.permanent_secretary?
  end

  test "should not be a cabinet member" do
    role = build(:special_representative_role)
    refute role.cabinet_member?
  end

  test "should not be a chief of the defence staff" do
    role = build(:special_representative_role)
    refute role.chief_of_the_defence_staff?
  end
end
