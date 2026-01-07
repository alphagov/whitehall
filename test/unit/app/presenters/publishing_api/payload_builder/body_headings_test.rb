require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderBodyHeadingsTest < ActiveSupport::TestCase
      test "returns an array of level 2 headers if they are found in the body" do
        govspeak = "##Heading 2 \n\nSome stuff\n\n"

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
          }],
        }

        assert_equal BodyHeadings.for(govspeak), expected_headers
      end

      test "returns an array including level 3 headers if they are found in the body" do
        govspeak = "##Heading 2 \n\nSome stuff\n\n###Heading 3\n\nSome stuff\n\n"

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

        assert_equal BodyHeadings.for(govspeak), expected_headers
      end

      test "returns empty map if there are no headers in the body" do
        govspeak = "Some stuff"

        assert_equal BodyHeadings.for(govspeak), {}
      end
    end
  end
end
