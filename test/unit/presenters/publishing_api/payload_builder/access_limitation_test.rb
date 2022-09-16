require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AccessLimitationTest < ActiveSupport::TestCase
      test "returns access limitation data for the item" do
        organisation = create(:organisation)
        user = create(:user, organisation:)

        stubbed_item = stub(
          access_limited?: true,
          publicly_visible?: false,
          organisations: [organisation],
        )
        expected_hash = {
          access_limited: {
            users: [user.uid],
          },
        }

        assert_equal AccessLimitation.for(stubbed_item), expected_hash
      end

      test "ignores users with no UID" do
        organisation = create(:organisation)
        create(:user, organisation:, uid: nil)

        stubbed_item = stub(
          access_limited?: true,
          publicly_visible?: false,
          organisations: [organisation],
        )

        assert_equal [], AccessLimitation.for(stubbed_item)[:access_limited][:users]
      end

      test "it returns an empty hash if the item is not access limited" do
        stubbed_item = stub(access_limited?: false, publicly_visible?: false)

        assert_equal({}, AccessLimitation.for(stubbed_item))
      end

      test "it returns an empty hash if the item is publicly visible" do
        stubbed_item = stub(access_limited?: true, publicly_visible?: true)

        assert_equal({}, AccessLimitation.for(stubbed_item))
      end

      test "it returns an empty hash if the item is publicly visible and not access limited" do
        stubbed_item = stub(access_limited?: false, publicly_visible?: true)

        assert_equal({}, AccessLimitation.for(stubbed_item))
      end
    end
  end
end
