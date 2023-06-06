require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PoliticalDetailsTest < ActiveSupport::TestCase
      test "returns political details for the item" do
        stubbed_item = stub(
          political?: true,
        )
        expected_hash = {
          political: true,
        }

        assert_equal PoliticalDetails.for(stubbed_item), expected_hash
      end
    end
  end
end
