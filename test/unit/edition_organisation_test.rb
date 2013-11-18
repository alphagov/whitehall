require 'test_helper'

class EditionOrganisationTest < ActiveSupport::TestCase
  test "should be invalid without an edition" do
    edition_organisation = build(:edition_organisation, edition: nil)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:edition].present?
  end

  test "should be invalid without an organisation" do
    edition_organisation = build(:edition_organisation, organisation: nil)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:organisation].present?
  end
end