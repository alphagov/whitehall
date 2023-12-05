require "test_helper"

class EditionWorldwideOrganisationTest < ActiveSupport::TestCase
  test "should be invalid without an edition" do
    edition_worldwide_organisation = build(:edition_worldwide_organisation, edition: nil)
    assert_not edition_worldwide_organisation.valid?
    assert edition_worldwide_organisation.errors[:edition].present?
  end

  test "should be invalid without an organisation" do
    edition_worldwide_organisation = build(:edition_worldwide_organisation, legacy_worldwide_organisation: nil)
    assert_not edition_worldwide_organisation.valid?

    # WILL THIS SURFACE ON THE FORM? PROBABLY NOT!
    assert edition_worldwide_organisation.errors[:legacy_worldwide_organisation].present?
  end
end
