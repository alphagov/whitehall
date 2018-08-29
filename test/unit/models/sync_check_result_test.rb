require 'test_helper'

class SyncCheckResultTest < ActiveSupport::TestCase
  test ".record performs an upsert" do
    SyncCheckResult.record("Foo", 1234, %w[bar])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal %w[bar], result.failures

    SyncCheckResult.record("Foo", 1234, %w[baz])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal %w[baz], result.failures

    SyncCheckResult.record("Qux", 1234, %w[baz])
    result = SyncCheckResult.first
    assert_equal "Foo", result.check_class
    assert_equal 1234, result.item_id
    assert_equal %w[baz], result.failures

    result = SyncCheckResult.last
    assert_equal "Qux", result.check_class
    assert_equal 1234, result.item_id
    assert_equal %w[baz], result.failures
  end
end
