require "test_helper"

module PublishingApi
  module PayloadBuilder
    class TagDetailsTest < ActiveSupport::TestCase
      test "returns tag details for the item" do
        stubbed_item = stub
        expected_hash = {
          tags: {
            browse_pages: [],
          },
        }

        assert_equal TagDetails.for(stubbed_item), expected_hash
      end
    end
  end
end
