require 'minitest/autorun'
require 'mocha/setup'
require_relative '../../../lib/sync_checker/result_set'
require_relative '../../../config/environment'

module SyncChecker
  class ResultSetTest < Minitest::Test
    def test_adding_nil_result_is_excluded_from_results
      result_set = ResultSet.new(stub)
      result_set << nil
      assert_equal 0, result_set.results.length
    end
  end
end
