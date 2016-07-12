require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PoliticalDetailsTest < ActiveSupport::TestCase
      test "returns political details for the item" do
        government = create(:government, name: "Foo")
        stubbed_item = stub(
          political?: true,
          government: government,
        )
        expected_hash = {
          political: true,
          government: {
            title: "Foo",
            slug: government.slug,
            current: true,
          }
        }

        assert_equal PoliticalDetails.for(stubbed_item), expected_hash
      end
    end
  end
end
