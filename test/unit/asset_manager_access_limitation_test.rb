require "test_helper"

class AssetManagerAccessLimitationTest < ActiveSupport::TestCase
  test 'delegates to PublishingApi::PayloadBuilder::AccessLimitation to ask for users that can access item' do
    edition = FactoryBot.build(:edition)
    access_limitation = { access_limited: { users: ['uid-1'] } }
    PublishingApi::PayloadBuilder::AccessLimitation.stubs(:for).with(edition).returns(access_limitation)
    assert_equal ['uid-1'], AssetManagerAccessLimitation.for(edition)
  end
end
