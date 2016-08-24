require 'minitest/autorun'
require 'mocha/setup'
require_relative "../../../lib/sync_checker/result_set"

class ResultSetTest < Minitest::Test
  def test_adding_result_increments_the_progress_bar
    result_set = SyncChecker::ResultSet.new(progress_bar = stub(increment: true))
    progress_bar.expects(:increment)
    result_set << Object.new
  end

  def test_adding_nil_result_increments_the_progress_bar_but_is_excluded_from_results
    result_set = SyncChecker::ResultSet.new(progress_bar = stub(increment: true))
    progress_bar.expects(:increment)
    result_set << nil
    assert_equal 0, result_set.length
  end

  def test_added_result_exposed_at_index
    result_set = SyncChecker::ResultSet.new(stub(increment: true))
    result_set << item = stub
    assert_equal item, result_set[0]
  end

  def test_length_delegated
    result_set = SyncChecker::ResultSet.new(stub(increment: true))
    result_set << stub
    result_set << stub
    assert_equal 2, result_set.length
  end

  def test_map_delegated
    result_set = SyncChecker::ResultSet.new(stub(increment: true))
    result_set << stub(id: 1)
    result_set << stub(id: 2)
    assert_equal [1, 2], result_set.map(&:id)
  end

  def test_each_delegated
    result_set = SyncChecker::ResultSet.new(stub(increment: true))
    result_set << stub(id: 1)
    result_set << stub(id: 2)
    count = 0
    result_set.each { count += 1 }
    assert_equal 2, count
  end
end
