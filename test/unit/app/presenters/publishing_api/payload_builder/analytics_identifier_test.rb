require "test_helper"

module PublishingApi
  module PayloadBuilder
    class AnalyticsIdentifierTest < ActiveSupport::TestCase
      test "returns the analytics identifier for an item " do
        stubbed_item = stub(analytics_identifier: "foo")

        assert_equal({ analytics_identifier: "foo" }, AnalyticsIdentifier.for(stubbed_item))
      end
    end
  end
end
