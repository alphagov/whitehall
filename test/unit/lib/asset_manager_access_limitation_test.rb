require "test_helper"

class AssetManagerAccessLimitationTest < ActiveSupport::TestCase
  test ".for delegates to PublishingApi::PayloadBuilder::AccessLimitation for organisations access limiting" do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { organisations: %w[org-1] } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_equal %w[org-1], AssetManagerAccessLimitation.for(edition, :organisations)
  end

  test ".for delegates to PublishingApi::PayloadBuilder::AccessLimitation for individuals access limiting" do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { users: %w[user-1] } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_equal %w[user-1], AssetManagerAccessLimitation.for(edition, :users)
  end

  test ".for returns nil if no access limitation set for the type provided" do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { other_key: "other_value" } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_nil AssetManagerAccessLimitation.for(edition, :users)
  end

  test ".for returns nil if no access limitation found at all" do
    edition = FactoryBot.build(:edition)
    access_limitation = {}
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_nil AssetManagerAccessLimitation.for(edition, :organisations)
  end
end
