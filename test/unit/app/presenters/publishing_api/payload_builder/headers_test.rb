require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderHeaderTest < ActiveSupport::TestCase
      test "returns an array of level 2 headers if they are found in the body" do
        item = stub(body: "## Heading 2 \n\nSome stuff\n\n")

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
          }],
        }

        assert_equal Headers.for(item), expected_headers
      end

      test "returns an array including level 3 headers if they are found in the body" do
        item = stub(body: "## Heading 2 \n\nSome stuff\n\n### Heading 3\n\nSome stuff\n\n")

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
            headers: [{
              text: "Heading 3",
              level: 3,
              id: "heading-3",
            }],
          }],
        }

        assert_equal Headers.for(item), expected_headers
      end

      test "returns an empty array of headers if none are found in the body" do
        item = stub(body: "Some stuff")

        assert_equal 0, Headers.for(item)[:headers].count
      end
    end
  end
end
