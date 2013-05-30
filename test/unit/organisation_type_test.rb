require 'test_helper'

class OrganisationTypeTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    organisation_type = build(:organisation_type, name: nil)
    refute organisation_type.valid?
  end

  test "should be invalid without a unique name" do
    existing_organisation_type = create(:organisation_type)
    organisation_type = build(:organisation_type, name: existing_organisation_type.name)
    refute organisation_type.valid?
  end

  test "should be returnable in an ordering suitable for organisational listing" do
    type_names = [
      "Executive office",
      "Ministerial department",
      "Non-ministerial department",
      "Executive agency",
      "Executive non-departmental public body",
      "Advisory non-departmental public body",
      "Tribunal non-departmental public body",
      "Public corporation",
      "Independent monitoring body",
      "Ad-hoc advisory group",
      "Sub-organisation",
      "Other"
    ]
    type_names.shuffle.each { |t| create(:organisation_type, name: t) }

    types_in_order = OrganisationType.in_listing_order
    assert_equal type_names, types_in_order.map(&:name)
  end

  test "should be a department if it contains 'department' in the name" do
    organisation_type = build(:organisation_type, name: "Ministerial department")
    assert organisation_type.department?
  end

  test "should not be a department if it is non-departmental" do
    organisation_type = build(:organisation_type,
                              name: "Executive non-departmental public body")
    refute organisation_type.department?
  end

  test "should not be a department if it doesn't mention departments" do
    organisation_type = build(:organisation_type,
                              name: "Ad-hoc advisory group")
    refute organisation_type.department?
  end

  test "unlistable should include sub-organisations" do
    org_types = stub('org types')
    OrganisationType.expects(:where).with(name: "Sub-organisation").returns(org_types)
    assert_equal org_types, OrganisationType.unlistable
  end

  test "agency_or_public_body should exclude sub-organisations" do
    department = create(:organisation_type, name: "Ministerial department")
    group = create(:organisation_type, name: "Ad-hoc advisory group")
    sub_organisation = create(:organisation_type, name: "Sub-organisation")

    assert_same_elements [department, group], OrganisationType.agency_or_public_body
  end
end
