require "test_helper"

class SocialMediaAccountTest < ActiveSupport::TestCase
  test "should be invalid without a url" do
    account = build(:social_media_account, url: nil)
    refute account.valid?
  end

  test "should be invalid with a malformed url" do
    account = build(:social_media_account, url: "invalid-url")
    refute account.valid?
  end

  test "should be valid with a url with HTTP protocol" do
    account = build(:social_media_account, url: "http://example.com")
    assert account.valid?
  end

  test "should be valid with a url with HTTPS protocol" do
    account = build(:social_media_account, url: "https://example.com")
    assert account.valid?
  end

  test "should be invalid without a social media service" do
    account = build(:social_media_account, social_media_service_id: nil)
    refute account.valid?
  end
end
