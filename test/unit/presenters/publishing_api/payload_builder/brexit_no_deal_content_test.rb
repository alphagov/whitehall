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

        assert_equal expected_hash, BrexitNoDealContent.for(stubbed_item)
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

        assert_equal expected_hash, BrexitNoDealContent.for(stubbed_item)
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

        assert_equal expected_hash, BrexitNoDealContent.for(stubbed_item)
      end

      test "blank links are filtered out" do
        stubbed_item = stub(
          show_brexit_no_deal_content_notice: true,
          brexit_no_deal_content_notice_links: [
            BrexitNoDealContentNoticeLink.new(title: "", url: ""),
            BrexitNoDealContentNoticeLink.new(title: "Link", url: "https://www.example.com"),
          ],
        )

        expected_hash = {
          brexit_no_deal_notice: [
            {
              title: "Link",
              href: "https://www.example.com",
            },
          ],
        }

        assert_equal expected_hash, BrexitNoDealContent.for(stubbed_item)
      end

      test "links with leading/trailing whitespace are trimmed" do
        stubbed_item = stub(
          show_brexit_no_deal_content_notice: true,
          brexit_no_deal_content_notice_links: [
            BrexitNoDealContentNoticeLink.new(title: "FrontSpaceLink", url: "   https://www.example.com"),
            BrexitNoDealContentNoticeLink.new(title: "RearSpaceLink", url: "https://www.example.com   "),
          ],
        )

        expected_hash = {
          brexit_no_deal_notice: [
            {
              title: "FrontSpaceLink",
              href: "https://www.example.com",
            },
            {
              title: "RearSpaceLink",
              href: "https://www.example.com",
            },
          ],
        }

        assert_equal expected_hash, BrexitNoDealContent.for(stubbed_item)
      end
    end
  end
end
