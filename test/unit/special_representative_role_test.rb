require 'test_helper'

class SpecialRepresentativeRoleTest < ActiveSupport::TestCase
  test "can never be a permanent secretary" do
    role = build(:special_representative_role, permanent_secretary: true)
    refute role.permanent_secretary?
    refute role.permanent_secretary
  end

  test "can never be a cabinet member" do
    role = build(:special_representative_role, cabinet_member: true)
    refute role.cabinet_member?
    refute role.cabinet_member
  end

  test "can never be a chief of the defence staff" do
    role = build(:special_representative_role, chief_of_the_defence_staff: true)
    refute role.chief_of_the_defence_staff?
    refute role.chief_of_the_defence_staff
  end
end
