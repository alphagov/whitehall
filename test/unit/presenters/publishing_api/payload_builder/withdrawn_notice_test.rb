
require "test_helper"

module PublishingApi
  module PayloadBuilder
    class WithdrawnNoticeTest < ActiveSupport::TestCase
      test "returns a withdrawn notice" do
        stubbed_item = stub(
          withdrawn?: true,
          updated_at: Time.zone.now,
          unpublishing: stub(explanation: "foo")
        )
        Whitehall::GovspeakRenderer.any_instance.stubs(:govspeak_to_html).with("foo").returns("bar")
        expected_hash = {
          withdrawn_notice: {
            explanation: "bar",
            withdrawn_at: stubbed_item.updated_at
          }
        }

        assert_equal expected_hash, WithdrawnNotice.for(stubbed_item)
      end

      test "it returns an empty hash if the item is not withdrawn" do
        stubbed_item = stub(
          withdrawn?: false,
        )
        expected_hash = {}

        assert_equal expected_hash, WithdrawnNotice.for(stubbed_item)
      end

      test "doesn't set a value for explanation if the item doesn't have one" do
        stubbed_item = stub(
          withdrawn?: true,
          updated_at: Time.zone.now,
          unpublishing: stub
        )
        Whitehall::GovspeakRenderer.any_instance.expects(:govspeak_to_html).never

        assert_nil WithdrawnNotice.for(stubbed_item)[:withdrawn_notice][:explanation]
      end
    end
  end
end
