require 'test_helper'

class OrganisationTypeTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    organisation_type = build(:organisation_type)
    assert organisation_type.valid?
  end

  test "should be invalid without a name" do
    organisation_type = build(:organisation_type, name: nil)
    refute organisation_type.valid?
  end

  test "should be invalid without a unique name" do
    existing_organisation_type = create(:organisation_type)
    organisation_type = build(:organisation_type, name: existing_organisation_type.name)
    refute organisation_type.valid?
  end
end