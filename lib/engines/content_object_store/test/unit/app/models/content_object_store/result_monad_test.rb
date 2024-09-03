require "test_helper"

class ContentObjectStore::ResultMonadTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "holds and returns data about the outcome of a service call" do
    success_flag = true
    message = "Success"
    object = "Object"

    result = ContentObjectStore::ResultMonad.new(success_flag, message, object)

    assert_equal success_flag, result.success
    assert_equal message, result.message
    assert_equal object, result.object
  end

  test "all values are optional" do
    result = ContentObjectStore::ResultMonad.new(nil, nil, nil)

    assert_nil result.success
    assert_nil result.message
    assert_nil result.object
  end

  test "#success? returns true if the first argument is true" do
    assert_equal true, ContentObjectStore::ResultMonad.new(true, nil, nil).success?
  end

  test "#success? returns false if the first argument is false" do
    assert_equal false, ContentObjectStore::ResultMonad.new(false, nil, nil).success?
  end

  test "#failure? returns true if the first argument is false" do
    assert_equal true, ContentObjectStore::ResultMonad.new(false, nil, nil).failure?
  end

  test "#failure? returns false if the first argument is true" do
    assert_equal false, ContentObjectStore::ResultMonad.new(true, nil, nil).failure?
  end
end
