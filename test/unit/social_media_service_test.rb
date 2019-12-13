require "test_helper"

class SocialMediaServiceTest < ActiveSupport::TestCase
  test "should be invalid without a name" do
    social_media_service = build(:social_media_service, name: nil)
    assert_not social_media_service.valid?
  end

  test "should be invalid without a unique name" do
    existing_service = create(:social_media_service)
    social_media_service = build(:social_media_service, name: existing_service.name)
    assert_not social_media_service.valid?
  end

  test "should be valid when existing service has been persisted" do
    _existing_service = create(:social_media_service)
    social_media_service = build(:social_media_service)
    assert social_media_service.valid?
  end
end
