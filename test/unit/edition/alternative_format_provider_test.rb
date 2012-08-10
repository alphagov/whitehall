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
end