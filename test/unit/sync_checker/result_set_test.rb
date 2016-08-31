require 'minitest/autorun'
require 'mocha/setup'
require_relative '../../../lib/sync_checker/result_set'
require_relative '../../../config/environment'

module SyncChecker
  class ResultSetTest < Minitest::Test
    def test_adding_result_increments_the_progress_bar
      result_set = ResultSet.new(progress_bar = stub(increment: true, log: nil))
      progress_bar.expects(:increment)
      result_set << stub(document_id: 1, to_row: true)
    end

    def test_adding_nil_result_increments_the_progress_bar_but_is_excluded_from_results
      result_set = ResultSet.new(progress_bar = stub(increment: true))
      progress_bar.expects(:increment)
      result_set << nil
      assert_equal 0, result_set.results.length
    end
  end
end
