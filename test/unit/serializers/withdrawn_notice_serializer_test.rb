require "test_helper"

class WithdrawnNoticeSerializerTest < ActiveSupport::TestCase
  test "it includes withdraw notice when the item has been withdrawn" do
    stubbed_item = stub(withdrawn?: true)
    serializer = WithdrawnNoticeSerializer.new(stubbed_item)
    example_hash = { key: :value }
    stubbed_details = stub(as_json: example_hash)

    WithdrawnNoticeDetailsSerializer.stub(:new, stubbed_details) do
      assert_equal serializer.withdrawn_notice, example_hash
      assert_equal serializer.as_json, { withdrawn_notice: example_hash }
    end
  end

  test "it doesn't include withdraw notice when the item has not been withdrawn" do
    stubbed_item = stub(withdrawn?: false)
    serializer = WithdrawnNoticeSerializer.new(stubbed_item)

    assert_equal serializer.as_json, {}
  end
end
