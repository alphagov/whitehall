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

  test "social media links are invalid when a social media service is chosen but no URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links invalid: no URL provided for 'Facebook'"], block_content.errors.full_messages
  end

  test "social media links are invalid when a social media service is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "not-a-url" },
      { "social_media_service_name" => "Twitter", "url" => "http://linkedin.com" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links invalid: bad URL provided for 'Facebook'"], block_content.errors.full_messages
  end

  test "social media links are invalid if two of the same social media service are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_equal ["Social media links invalid: duplicate service 'Facebook'"], block_content.errors.full_messages
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
