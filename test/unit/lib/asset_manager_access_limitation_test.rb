require "test_helper"

class AssetManagerAccessLimitationTest < ActiveSupport::TestCase
  test "for_organisations delegates to PublishingApi::PayloadBuilder::AccessLimitation" do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { organisations: %w[org-1] } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_equal %w[org-1], AssetManagerAccessLimitation.for_organisations(edition)
  end

  test "for_users delegates to PublishingApi::PayloadBuilder::AccessLimitation" do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { users: %w[user-1] } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_equal %w[user-1], AssetManagerAccessLimitation.for_users(edition)
  end
end
