require "test_helper"

class SocialMediaLinksValidatorTest < ActiveSupport::TestCase
  setup do
    @social_media_service_1 = create(:social_media_service, name: "Facebook")
    @social_media_service_2 = create(:social_media_service, name: "LinkedIn")
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
    attr_accessor :social_media_links
  end

  test "empty social media links are valid" do
    block_content = SocialMediaLinksValidatorTestClass.new
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are invalid when none of social media service and URL are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains an account (\"Social media account 1\") without a service selected."], block_content.errors.full_messages
  end

  test "social media links are invalid when no social media service is chosen and a URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "https://facebook.com" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains an account (\"Social media account 1\") without a service selected."], block_content.errors.full_messages
  end

  test "social media links are invalid when a social media service is chosen but no URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains a \"Facebook\" account without a URL."], block_content.errors.full_messages
  end

  test "social media links are invalid when a social media service is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "not-a-url" },
      { "social_media_service_name" => "Twitter", "url" => "http://linkedin.com" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains a \"Facebook\" account with an invalid URL - use the full URL, including https://"], block_content.errors.full_messages
  end

  test "social media links are invalid if two of the same social media service are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains another account with a service of \"Facebook\"."], block_content.errors.full_messages
  end

  test "social media links are invalid if two services have the same URL" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Twiter", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links already has an account with a URL of \"http://facebook.com/govuk\"."], block_content.errors.full_messages
  end

  test "social media links are valid when multiple 'Other' services are provided with different URLs" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Other", "url" => "http://example.com/one" },
      { "social_media_service_name" => "Other", "url" => "http://example.com/two" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are valid when a social media service is chosen and a well-formed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "LinkedIn", "url" => "https://linkedin.com/company/govuk" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end
end
