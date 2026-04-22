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
    attr_accessor :social_media_links
  end

  test "empty social media links are valid" do
    block_content = SocialMediaLinksValidatorTestClass.new
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links with no duplicates are valid" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "LinkedIn", "url" => "https://linkedin.com/company/govuk" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are invalid if two of the same channel are provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "already has an account with a channel of \"Facebook\""
  end

  test "social media links are invalid if two channels have the same URL" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Twitter", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "already has an account with a URL of \"http://facebook.com/govuk\""
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

  test "does not flag blank channels or URLs as duplicates" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "" },
      { "social_media_service_name" => "", "url" => "" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end
end
