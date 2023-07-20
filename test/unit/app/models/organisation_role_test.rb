require "test_helper"

class OrganisationRoleTest < ActiveSupport::TestCase
  test "should be invalid without an organisation" do
    organisation_role = build(:organisation_role, organisation_id: nil)
    assert_not organisation_role.valid?
  end

  test "should be invalid without a role" do
    organisation_role = build(:organisation_role, role_id: nil)
    assert_not organisation_role.valid?
  end
end
