require "test_helper"

class SocialMediaLinksValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = SocialMediaLinksValidator.new({
      attributes: %w[social_media_links],
      fields: {
        "service_field" => "social_media_service_name",
        "url_field" => "url",
      },
    })
  end

  class SocialMediaLinksValidatorTestClass
    include ActiveModel::API
    include WithNestedAttributeErrors
    attr_accessor :social_media_links
  end

  test "empty social media links are valid" do
    block_content = SocialMediaLinksValidatorTestClass.new
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are invalid when both channel and URL are blank" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors["social_media_links.0.social_media_service_name".to_sym], "cannot be blank"
    assert_includes block_content.errors["social_media_links.0.url".to_sym], "cannot be blank"
  end

  test "social media links are invalid when no channel is chosen and a URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "https://facebook.com" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors["social_media_links.0.social_media_service_name".to_sym], "cannot be blank"
    assert_empty block_content.errors["social_media_links.0.url".to_sym]
  end

  test "social media links are invalid when a channel is chosen but no URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_empty block_content.errors["social_media_links.0.social_media_service_name".to_sym]
    assert_includes block_content.errors["social_media_links.0.url".to_sym], "cannot be blank"
  end

  test "social media links are invalid when a channel is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "not-a-url" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors["social_media_links.0.url".to_sym], "is invalid - use the full URL, including https://"
  end

  test "social media links are invalid when no channel is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "not-a-url" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors["social_media_links.0.social_media_service_name".to_sym], "cannot be blank"
    assert_includes block_content.errors["social_media_links.0.url".to_sym], "is invalid - use the full URL, including https://"
  end

  test "social media links are invalid if two of the same channel are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_empty block_content.errors["social_media_links.0.social_media_service_name".to_sym]
    assert_includes block_content.errors["social_media_links.1.social_media_service_name".to_sym], "must be unique"
  end

  test "social media links are invalid if two channels have the same URL" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Twitter", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
    ]
    @validator.validate(block_content)

    assert_empty block_content.errors["social_media_links.0.url".to_sym]
    assert_includes block_content.errors["social_media_links.1.url".to_sym], "must be unique"
  end

  test "social media links are valid when multiple 'Other' channels are provided with different URLs" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Other", "url" => "http://example.com/one" },
      { "social_media_service_name" => "Other", "url" => "http://example.com/two" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are valid when a channel is chosen and a well-formed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "LinkedIn", "url" => "https://linkedin.com/company/govuk" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end
end
