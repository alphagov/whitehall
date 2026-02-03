require "test_helper"

class GovUkUrlFormatValidatorTest < ActiveSupport::TestCase
  test "`can_be_converted_to_relative_path?` matches only 'proper' GOV.UK URLs" do
    # Production
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://www.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://www.gov.uk/some-path")
    # Test environments
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://www.integration.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://www.staging.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://www.integration.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://www.staging.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://integration.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://staging.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://integration.publishing.service.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://staging.publishing.service.gov.uk/some-path")
    # Local environments
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://www.test.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://www.dev.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://test.gov.uk/some-path")
    assert GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://dev.gov.uk/some-path")
  end

  test "doesn't match other gov.uk subdomains" do
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://foo.gov.uk/some-path")
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://foo.gov.uk/some-path")
  end
end
