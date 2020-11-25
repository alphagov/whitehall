require "test_helper"

module PublishingApi
  module PayloadBuilder
    class BrexitContentNoticesTest < ActiveSupport::TestCase
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

        assert_equal expected_hash, BrexitContentNotices.for(stubbed_item)
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

        assert_equal expected_hash, BrexitContentNotices.for(stubbed_item)
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

        assert_equal expected_hash, BrexitContentNotices.for(stubbed_item)
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

        assert_equal expected_hash, BrexitContentNotices.for(stubbed_item)
      end

      test "returns {} if there are no brexit content notices" do
        edition = create(:edition)
        assert_equal({}, BrexitContentNotices.for(edition))
      end

      test "builds Brexit current state notice content banner payload" do
        edition_with_current_state_notice = create(:edition, show_brexit_current_state_content_notice: true)
        expected_payload = { brexit_current_state_notice: [] }

        assert_equal expected_payload, BrexitContentNotices.for(edition_with_current_state_notice)
      end
    end
  end
end
