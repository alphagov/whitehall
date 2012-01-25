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

  test "should be returnable in an ordering suitable for organisational listing" do
    type_names = [
      "Ministerial department",
      "Non-ministerial department",
      "Executive agency",
      "Executive non-departmental public body",
      "Advisory non-departmental public body",
      "Tribunal non-departmental public body",
      "Public corporation",
      "Independent monitoring body",
      "Ad-hoc advisory group",
      "Other"
    ]
    type_names.shuffle.each { |t| create(:organisation_type, name: t) }

    types_in_order = OrganisationType.in_listing_order
    assert_equal type_names, types_in_order.map(&:name)
  end
end