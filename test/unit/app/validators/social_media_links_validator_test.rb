require "test_helper"

class SocialMediaLinksValidatorTest < ActiveSupport::TestCase
  setup do
    @social_media_service_1 = create(:social_media_service, name: "Facebook")
    @social_media_service_2 = create(:social_media_service, name: "LinkedIn")
    @validator = SocialMediaLinksValidator.new({
      attributes: %w[social_media_links],
      fields: {
        service_field: "social_media_service_id",
        url_field: "url",
      },
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
    assert_includes model.errors[:base], "Social media links cannot be blank"
    assert_not_includes model.errors[:base], "Social media links is not a valid URI. Make sure it starts with http(s)"
  end

  test "social media links are invalid when a social media service is chosen and a malformed URL is provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "not-a-url" },
      { "social_media_service_id" => @social_media_service_2.id, "url" => "http://linkedin.com" },
    ]
    @validator.validate(model)

    assert_includes model.errors[:base], "Social media links is not a valid URI. Make sure it starts with http(s)"
  end

  test "social media links are INVALID if two of the same social media service are provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => @social_media_service_1.id, "url" => "http://facebook.com/govuk" },
      { "social_media_service_id" => @social_media_service_1.id, "url" => "http://facebook.com/govukpage2" },
    ]
    @validator.validate(model)

    assert_includes model.errors[:base], "Social media accounts invalid: duplicate service 'Facebook'"
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

  test "social media links are VALID if two 'Other' services are provided" do
    model = SocialMediaLinksValidatorTestClass.new
    model.social_media_links = [
      { "social_media_service_id" => "other", "url" => "http://foo.com" },
      { "social_media_service_id" => "other", "url" => "http://bar.com" },
    ]
    @validator.validate(model)

    assert model.errors.empty?
  end
end
