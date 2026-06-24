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
        "title_field" => "title",
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

  test "social media links are invalid when both channel and URL are blank" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 1 service name cannot be blank"
    assert_includes block_content.errors[:social_media_links], "Social media channel 1 URL cannot be blank"
    assert_equal 2, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when no channel is chosen and a URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "https://facebook.com" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 1 service name cannot be blank"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when a channel is chosen but no URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 1 URL cannot be blank"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when a channel is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "not-a-url" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 1 URL is invalid - use the full URL, including https://"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when no channel is chosen and a malformed URL is provided" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "", "url" => "not-a-url" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 1 service name cannot be blank"
    assert_includes block_content.errors[:social_media_links], "Social media channel 1 URL is invalid - use the full URL, including https://"
    assert_equal 2, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid if two channels have the same URL" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Twitter", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 2 URL must be unique"
    assert_equal 1, block_content.errors[:social_media_links].size
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

  test "social media links are valid when titles are unique" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk", "title" => "GOV.UK on Facebook" },
      { "social_media_service_name" => "Twitter", "url" => "http://twitter.com/govuk", "title" => "GOV.UK on Twitter" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are valid when titles are blank" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk", "title" => "" },
      { "social_media_service_name" => "Twitter", "url" => "http://twitter.com/govuk", "title" => "" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end

  test "social media links are invalid when any two accounts have the same title" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "title" => "Our updates", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Twitter", "title" => "Our updates", "url" => "http://twitter.com/govuk" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 2 title must be unique"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when multiple instances of the same channel are provided, with no distinct titles" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 2 title must be unique"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid when multiple 'Other' channels are provided, with no distinct titles" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Other", "url" => "http://example.com/one" },
      { "social_media_service_name" => "Other", "url" => "http://example.com/two" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 2 title must be unique"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are invalid and only display title uniqueness error, if multiple instances of the same channel are provided, and their titles match" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "title" => "Facebook", "url" => "http://facebook.com/govuk" },
      { "social_media_service_name" => "Facebook", "title" => "Facebook", "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(block_content)

    assert_includes block_content.errors[:social_media_links], "Social media channel 2 title must be unique"
    assert_equal 1, block_content.errors[:social_media_links].size
  end

  test "social media links are valid when multiple instances of the same channel are provided with different titles and different URLs" do
    block_content = SocialMediaLinksValidatorTestClass.new
    block_content.social_media_links = [
      { "social_media_service_name" => "Facebook", "title" => "Facebook Corporate", "url" => "http://example.com/one" },
      { "social_media_service_name" => "Facebook", "title" => "Facebook Fun", "url" => "http://example.com/two" },
    ]
    @validator.validate(block_content)

    assert block_content.errors.empty?
  end
end
