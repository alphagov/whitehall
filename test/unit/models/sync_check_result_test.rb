require 'test_helper'

class SyncCheckResultTest < ActiveSupport::TestCase
  test ".record performs an upsert" do
    SyncCheckResult.record("Foo", 1234, ["bar"])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal ["bar"], result.failures

    SyncCheckResult.record("Foo", 1234, ["baz"])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal ["baz"], result.failures

    SyncCheckResult.record("Qux", 1234, ["baz"])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal ["baz"], result.failures

    result = SyncCheckResult.last
    assert_equal "Qux", result.check_class
    assert_equal 1234, result.item_id
    assert_equal ["baz"], result.failures
  end
end
