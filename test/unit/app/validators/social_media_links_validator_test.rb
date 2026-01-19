require "test_helper"

class SocialMediaLinksValidatorTest < ActiveSupport::TestCase
  setup do
    @social_media_service_1 = create(:social_media_service, name: "Facebook")
    @social_media_service_2 = create(:social_media_service, name: "LinkedIn")
    @validator = SocialMediaLinksValidator.new({
      attributes: %w[social_media_links],
      service_field: "social_media_service_id",
      url_field: "url",
    })
  end

  class SocialMediaLinksValidatorTestClass
    include ActiveModel::API
    attr_accessor :social_media_links
  end

  test "empty social media links are valid" do
    model = SocialMediaLinksValidatorTestClass.new
    @validator.validate(model)

    assert model.errors.empty?
  end

  test "social media links are invalid when a social media service is chosen but no URL is provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "" },
    ]
    @validator.validate(model)

    assert_equal ["Social media links invalid: no URL provided for 'Facebook'"], model.errors.full_messages
  end

  test "social media links are invalid when a social media service is chosen and a malformed URL is provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "not-a-url" },
      { "social_media_service_id" => @social_media_service_2.id, "url" => "http://linkedin.com" },
    ]
    @validator.validate(model)

    assert_equal ["Social media links invalid: bad URL provided for 'Facebook'"], model.errors.full_messages
  end

  test "social media links are invalid if social media service isn't a known SocialMediaService" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => "-1", "url" => "http://example.com" },
    ]
    @validator.validate(model)

    assert_equal ["Social media links invalid: unknown service with ID '-1'"], model.errors.full_messages
  end

  test "social media links are invalid if two of the same social media service are provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "http://facebook.com/govuk" },
      { "social_media_service_id" => @social_media_service_1.id, "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(model)

    assert_equal ["Social media links invalid: duplicate service 'Facebook'"], model.errors.full_messages
  end

  test "social media links are valid when a social media service is chosen and a well-formed URL is provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "http://facebook.com/govuk" },
      { "social_media_service_id" => @social_media_service_2.id, "url" => "https://linkedin.com/company/govuk" },
    ]
    @validator.validate(model)

    assert model.errors.empty?
  end
end
