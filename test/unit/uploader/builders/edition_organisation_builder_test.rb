require "test_helper"

class Whitehall::Uploader::Builders::EditionOrganisationBuilderTest < ActiveSupport::TestCase
  test "does nothing if the supplied organisation is blank" do
    edition_organisation = Whitehall::Uploader::Builders::EditionOrganisationBuilder.build_lead(nil)
    assert edition_organisation.nil?
  end

  test "stores the organisation" do
    o = Organisation.new
    edition_organisation = Whitehall::Uploader::Builders::EditionOrganisationBuilder.build_lead(o)
    assert_equal o, edition_organisation.organisation
  end

  test "stores the supplied ordering" do
    o = Organisation.new
    edition_organisation = Whitehall::Uploader::Builders::EditionOrganisationBuilder.build_lead(o, 12)
    assert_equal 12, edition_organisation.lead_ordering
  end

  test "sets the lead_ordering to 1 if not supplied" do
    o = Organisation.new
    edition_organisation = Whitehall::Uploader::Builders::EditionOrganisationBuilder.build_lead(o)
    assert_equal 1, edition_organisation.lead_ordering
  end

  test "sets the lead to true" do
    o = Organisation.new
    edition_organisation = Whitehall::Uploader::Builders::EditionOrganisationBuilder.build_lead(o)
    assert edition_organisation.lead
  end
end
