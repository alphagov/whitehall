require "test_helper"

module PublishingApi
  module PayloadBuilder
    class BrexitNoDealContentTest < ActiveSupport::TestCase
      test "builds Brexit no-deal content banner payload with links" do
        stubbed_item = stub(
          show_brexit_no_deal_content_notice: true,
          brexit_no_deal_content_notice_links: [
            BrexitNoDealContentNoticeLink.new(title: "Link 1", url: "https://www.example.com/1"),
            BrexitNoDealContentNoticeLink.new(title: "Link 2", url: "https://www.example.com/2"),
          ],
        )

        expected_hash = {
          brexit_no_deal_notice: [
            {
              title: "Link 1",
              href: "https://www.example.com/1",
            },
            {
              title: "Link 2",
              href: "https://www.example.com/2",
            },
          ],
        }

        assert_equal BrexitNoDealContent.for(stubbed_item), expected_hash
      end

      test "builds Brexit no-deal content banner payload with no links" do
        stubbed_item = stub(
          show_brexit_no_deal_content_notice: false,
          brexit_no_deal_content_notice_links: [
            BrexitNoDealContentNoticeLink.new(title: "Link 1", url: "https://www.example.com/1"),
            BrexitNoDealContentNoticeLink.new(title: "Link 2", url: "https://www.example.com/2"),
          ],
        )

        expected_hash = {}

        assert_equal BrexitNoDealContent.for(stubbed_item), expected_hash
      end

      test "internal links expose only the URL path" do
        stubbed_item = stub(
          show_brexit_no_deal_content_notice: true,
          brexit_no_deal_content_notice_links: [
            BrexitNoDealContentNoticeLink.new(title: "Internal", url: "https://www.gov.uk/1"),
            BrexitNoDealContentNoticeLink.new(title: "External", url: "https://www.example.com/2"),
          ],
        )

        expected_hash = {
          brexit_no_deal_notice: [
            {
              title: "Internal",
              href: "/1",
            },
            {
              title: "External",
              href: "https://www.example.com/2",
            },
          ],
        }

        assert_equal BrexitNoDealContent.for(stubbed_item), expected_hash
      end
    end
  end
end
