require "test_helper"

class GovUkUrlFormatValidatorTest < ActiveSupport::TestCase
  test "matches GOV.UK URLs" do
    # Production
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://www.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://www.gov.uk")
    # Test environments
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://www.integration.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://www.staging.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://www.integration.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://www.staging.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://integration.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("https://staging.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://integration.publishing.service.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://staging.publishing.service.gov.uk")
    # Local environments
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://www.test.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://www.dev.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://test.gov.uk")
    assert GovUkUrlFormatValidator.matches_gov_uk?("http://dev.gov.uk")
  end

  test "doesn't match other gov.uk subdomains" do
    assert_not GovUkUrlFormatValidator.matches_gov_uk?("https://foo.gov.uk")
    assert_not GovUkUrlFormatValidator.matches_gov_uk?("http://foo.gov.uk")
  end
end
