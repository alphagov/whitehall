require "test_helper"

module PublishingApi
  module PayloadBuilder
    class PayloadBuilderBodyHeadingsTest < ActiveSupport::TestCase
      test "returns an array of level 2 headers if they are found in the body" do
        item = stub(body: "##Heading 2 \n\nSome stuff\n\n")

        expected_headers = {
          headers: [{
            text: "Heading 2",
            level: 2,
            id: "heading-2",
          }],
        }

        assert_equal BodyHeadings.for(item), expected_headers
      end

      test "returns an array including level 3 headers if they are found in the body" do
        item = stub(body: "##Heading 2 \n\nSome stuff\n\n###Heading 3\n\nSome stuff\n\n")

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

        assert_equal BodyHeadings.for(item), expected_headers
      end

      test "returns empty map if there are no headers in the body" do
        item = stub(body: "Some stuff")

        assert_equal BodyHeadings.for(item), {}
      end

      test "filters out govspeak links from the headers text" do
        item = stub(body: "##Normal Heading\n\nSome stuff\n\n##[Link Heading](https://www.example.com)\n\nSome stuff\n\n")

        expected_headers = {
          headers: [
            {
              text: "Normal Heading",
              level: 2,
              id: "normal-heading",
            },
            {
              text: "Link Heading",
              level: 2,
              id: "link-heading",
            },
          ],
        }

        assert_equal BodyHeadings.for(item), expected_headers
      end
    end
  end
end
