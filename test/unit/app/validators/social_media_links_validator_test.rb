require "test_helper"

class SocialMediaLinksValidatorTest < ActiveSupport::TestCase
  setup do
    @social_media_channel_1 = create(:social_media_service, name: "Facebook")
    @social_media_channel_2 = create(:social_media_service, name: "LinkedIn")
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

    # Errors are added with dotted attribute names e.g. :"social_media_links.0.url".
    # Rails tries to call these as methods, which would raise NoMethodError since dots
    # aren't valid in Ruby method names. BlockContent handles this in production; we
    # replicate it here.
    def method_missing(method_name, *args)
      method_name.to_s.include?(".") ? nil : super
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.include?(".") || super
    end
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

    assert_equal [
      "Social media links 0 social media service name cannot be blank (account 1)",
      "Social media links 0 url cannot be blank (account 1)",
    ], block_content.errors.full_messages
  end

  test "social media links are invalid when no channel is chosen and a URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "https://facebook.com" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links 0 social media service name cannot be blank (account 1)"], block_content.errors.full_messages
  end

  test "social media links are invalid when a channel is chosen but no URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links 0 url cannot be blank (account 1)"], block_content.errors.full_messages
  end

  test "social media links are invalid when a channel is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "not-a-url" },
      { "social_media_service_name" => "Twitter", "url" => "http://linkedin.com" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains a \"Facebook\" account with an invalid URL - use the full URL, including https://"], block_content.errors.full_messages
  end

  test "social media links are invalid if two of the same channel are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links contains another account with a channel of \"Facebook\"."], block_content.errors.full_messages
  end

  test "social media links are invalid if two channels have the same URL" do
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
