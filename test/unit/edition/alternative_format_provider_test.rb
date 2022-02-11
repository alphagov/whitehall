require "test_helper"

class Edition::AlternativeFormatProviderTest < ActiveSupport::TestCase
  class EditionWithAlternativeFormat < Edition
    include ::Edition::AlternativeFormatProvider
  end

  test "should be able to record the organisation responsible for providing publications in alternative formats" do
    edition = EditionWithAlternativeFormat.new
    edition.alternative_format_provider = build(:organisation)
  end

  test "should have alternative_format_contact_email if alternative_format_provider specified" do
    email_address = "alternative.format@example.com"
    edition = EditionWithAlternativeFormat.new
    edition.alternative_format_provider = build(:organisation, alternative_format_contact_email: email_address)
    assert_equal email_address, edition.alternative_format_contact_email
  end

  test "should use govuk-feedback if not set" do
    edition = EditionWithAlternativeFormat.new
    assert_equal "govuk-feedback@digital.cabinet-office.gov.uk", edition.alternative_format_contact_email
  end

  test "should use govuk-feedback if blank" do
    edition = EditionWithAlternativeFormat.new
    edition.alternative_format_provider = build(:organisation, alternative_format_contact_email: "")
    assert_equal "govuk-feedback@digital.cabinet-office.gov.uk", edition.alternative_format_contact_email
  end

  test "organisation providing publications is taking part in the accessible format request pilot" do
    organisation_in_pilot = build(:organisation, id: 6)
    edition = EditionWithAlternativeFormat.new
    edition.alternative_format_provider = organisation_in_pilot
    assert_equal true, edition.organisation_in_accessible_format_request_pilot?
  end

  test "organisation providing publications is not taking part in the accessible format request pilot" do
    organisation_not_in_pilot = build(:organisation, id: 1)
    edition = EditionWithAlternativeFormat.new
    edition.alternative_format_provider = organisation_not_in_pilot
    assert_equal false, edition.organisation_in_accessible_format_request_pilot?
  end
end
