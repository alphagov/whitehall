require "test_helper"

class GovUkUrlFormatValidatorTest < ActiveSupport::TestCase
  setup do
    @klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :url

      validates :url, gov_uk_url_format: true
    end
  end

  test "considers asset URLs to be valid (for redirect purposes)" do
    model = @klass.new(url: "https://assets.publishing.service.gov.uk/media/id/foo.pdf")
    assert model.valid?

    model.url = "https://assets.staging.publishing.service.gov.uk/media/id/foo.pdf"
    assert model.valid?

    model.url = "https://assets.integration.publishing.service.gov.uk/media/id/foo.pdf"
    assert model.valid?
  end

  test "considers .gov.uk subdomains to be valid (for redirect purposes)" do
    model = @klass.new(url: "https://foo.gov.uk/bar")
    assert model.valid?
  end

  test "considers allow-listed non-GOV.UK external domains to be valid (for redirect purposes)" do
    model = @klass.new(url: "https://www.independent-inquiry.uk/about-the-independent-inquiry/")
    assert model.valid?

    model.url = "http://www.nhs.uk/some-page"
    assert model.valid?

    model.url = "https://caa.co.uk/some-page"
    assert model.valid?

    model.url = "https://example.com/some-page"
    assert_not model.valid?
  end

  test "considers internal draft stack URLs to be invalid (for redirect purposes)" do
    model = @klass.new(url: "https://draft-origin.publishing.service.gov.uk/some-path")
    assert_not model.valid?

    model.url = "http://draft-origin.publishing.service.gov.uk/some-path"
    assert_not model.valid?
  end

  test "considers internal publishing app URLs to be invalid (for redirect purposes)" do
    model = @klass.new(url: "https://whitehall-admin.publishing.service.gov.uk/some-path")
    assert_not model.valid?

    model.url = "http://whitehall-admin.publishing.service.gov.uk/some-path"
    assert_not model.valid?

    model.url = "https://publisher.integration.publishing.service.gov.uk/some-path"
    assert_not model.valid?
  end

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

  test "doesn't match the asset subdomain" do
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://assets.publishing.service.gov.uk/some-path")
  end

  test "doesn't match the publishing app subdomains" do
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://whitehall-admin.publishing.service.gov.uk/some-path")
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("http://publisher.integration.publishing.service.gov.uk/some-path")
  end

  test "doesn't match the draft stack subdomain" do
    assert_not GovUkUrlFormatValidator.can_be_converted_to_relative_path?("https://draft-origin.publishing.service.gov.uk/some-path")
  end
end
