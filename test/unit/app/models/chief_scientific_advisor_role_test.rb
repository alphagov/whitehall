require "test_helper"

class ChiefScientificAdvisorRoleTest < ActiveSupport::TestCase
  test "should not be a permanent secretary" do
    chief_scientific_advisor_role = build(:chief_scientific_advisor_role)
    assert_not chief_scientific_advisor_role.permanent_secretary?
  end

  test "should not be a cabinet member" do
    chief_scientific_advisor_role = build(:chief_scientific_advisor_role)
    assert_not chief_scientific_advisor_role.cabinet_member?
  end
end
