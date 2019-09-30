require "test_helper"

class SocialMediaAccountTest < ActiveSupport::TestCase
  test "should be invalid without a url" do
    account = build(:social_media_account, url: nil)
    refute account.valid?
    assert_includes account.errors.full_messages, "Url can't be blank"
  end

  test "should be invalid with a malformed url" do
    account = build(:social_media_account, url: "invalid-url", social_media_service: create(:social_media_service))
    refute account.valid?
    assert_includes account.errors.full_messages, "Url is not valid. Make sure it starts with http(s)"
  end

  test "should be valid with a url with HTTP protocol" do
    account = create(:social_media_account, url: "http://example.com")
    assert account.valid?
  end

  test "should be valid with a url with HTTPS protocol" do
    account = create(:social_media_account, url: "https://example.com")
    assert account.valid?
  end

  test "should be invalid without a social media service" do
    account = build(:social_media_account, social_media_service_id: nil)
    refute account.valid?
    assert_includes account.errors.full_messages, "Social media service can't be blank"
  end

  test "is invalid if the title is longer than 255 characters" do
    account = create(:social_media_account, title: "a" * 254) # just under
    assert account.valid?
    account.title = "a" * 255 # exactly maximum
    assert account.valid?
    account.title = "a" * 256 # just over
    refute account.valid?
  end

  test "display_name is the title if present" do
    account = build(:social_media_account, title: "My face")
    assert_equal "My face", account.display_name
  end

  test "display_name is the name of the service if the title is blank" do
    sms = build(:social_media_service, name: "Facebark")
    account = build(:social_media_account, title: "", social_media_service: sms)
    assert_equal "Facebark", account.display_name
  end
end
