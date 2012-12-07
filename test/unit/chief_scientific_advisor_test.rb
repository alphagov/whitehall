require 'test_helper'

class ChiefScientificAdvisorTest < ActiveSupport::TestCase
  test "can never be a permanent secretary" do
    chief_scientific_advisor_role = build(:chief_scientific_advisor_role, permanent_secretary: true)
    refute chief_scientific_advisor_role.permanent_secretary?
    refute chief_scientific_advisor_role.permanent_secretary
  end

  test "can never be a cabinet member" do
    chief_scientific_advisor_role = build(:chief_scientific_advisor_role, cabinet_member: true)
    refute chief_scientific_advisor_role.cabinet_member?
    refute chief_scientific_advisor_role.cabinet_member
  end
end
