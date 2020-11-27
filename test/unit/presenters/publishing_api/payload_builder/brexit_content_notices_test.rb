require "test_helper"

module PublishingApi
  module PayloadBuilder
    class BrexitContentNoticesTest < ActiveSupport::TestCase
      extend Minitest::Spec::DSL

      test "returns {} if there are no transition content notices" do
        edition = create(:edition,
                         show_brexit_no_deal_content_notice: false,
                         show_brexit_current_state_content_notice: false)
        assert_equal({}, BrexitContentNotices.for(edition))
      end

      context "no-deal content notices" do
        test "builds Brexit no-deal content banner payload with links" do
          title = "Link 1"
          url = "https://www.example.com/1"
          stubbed_item = stub(
            show_brexit_no_deal_content_notice: true,
            brexit_no_deal_content_notice_links: [
              BrexitNoDealContentNoticeLink.new(title: title, url: url),
            ],
            show_brexit_current_state_content_notice: false,
          )

          expected_hash = {
            brexit_no_deal_notice: [
              {
                title: title,
                href: url,
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
            show_brexit_current_state_content_notice: false,
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
            show_brexit_current_state_content_notice: false,
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
            show_brexit_current_state_content_notice: false,
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
      end

      context "current state content notices" do
        test "builds Brexit current state notice content payload with links" do
          stubbed_item = stub(
            show_brexit_current_state_content_notice: true,
            brexit_current_state_content_notice_links: [
              BrexitCurrentStateContentNoticeLink.new(title: "Link", url: "https://www.example.com"),
            ],
            show_brexit_no_deal_content_notice: false,
          )
          expected_payload = {
            brexit_current_state_notice: [
              {
                title: "Link",
                href: "https://www.example.com",
              },
            ],
          }
          assert_equal expected_payload, BrexitContentNotices.for(stubbed_item)
        end

        test "does not add links to the payload if show_current_state_notice is false" do
          stubbed_item = stub(
            show_brexit_current_state_content_notice: false,
            brexit_current_state_content_notice_links: [
              BrexitCurrentStateContentNoticeLink.new(title: "Link", url: "https://www.example.com"),
            ],
            show_brexit_no_deal_content_notice: false,
          )
          expected_payload = {}
          assert_equal expected_payload, BrexitContentNotices.for(stubbed_item)
        end
      end
    end
  end
end
