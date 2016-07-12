require "test_helper"
require 'active_model_serializers'

class AccessLimitationSerializerTest < ActiveSupport::TestCase
  test "it includes access limited attribute when it as limited access" do
    stubbed_item = stub(
      access_limited?: true,
      publicly_visible?: false,
      organisations: []
    )
    serializer = AccessLimitationSerializer.new(stubbed_item)
    expected_access_limited = { users: [] }

    assert_equal serializer.access_limited, expected_access_limited
    assert_equal serializer.as_json, { access_limited: expected_access_limited }
  end

  test "it doesn't include access limited attribute when it as no limited access" do
    stubbed_item = stub(
      access_limited?: false,
      publicly_visible?: true,
      organisations: []
    )
    serializer = AccessLimitationSerializer.new(stubbed_item)

    assert_equal serializer.as_json, {}
  end
end
