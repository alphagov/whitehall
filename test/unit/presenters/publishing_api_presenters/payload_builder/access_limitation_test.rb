require "test_helper"

module PublishingApiPresenters
  module PayloadBuilder
    class AccessLimitationTest < ActiveSupport::TestCase
      test "returns access limitation data for the item" do
        organisation = create(:organisation)
        user = create(:user, organisation: organisation)

        stubbed_item = stub(
          access_limited?: true,
          publicly_visible?: false,
          organisations: [organisation]
        )
        expected_hash = {
          access_limited: {
            users: [user.uid]
          }
        }

        assert_equal AccessLimitation.for(stubbed_item), expected_hash
      end
    end
  end
end
