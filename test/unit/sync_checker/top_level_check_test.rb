require 'minitest/autorun'
require 'mocha/setup'
require 'active_support/json'
require_relative '../../../lib/sync_checker/top_level_check'

module SyncChecker
  class TopLevelCheckTest < Minitest::Test
    def test_returns_empty_array_when_expected_are_present_in_response_body
      response = stub(response_code: 200, body: {
        test: "ers",
        check: "ered"
      }.to_json)

      expected = {
        test: "ers",
        check: "ered"
      }

      results = TopLevelCheck.new(expected).call(response)
      assert_equal [], results
    end

    def test_returns_an_array_of_error_messages_when_expected_not_found
      response = stub(response_code: 200, body: {
        test: "ers",
        check: "mate"
      }.to_json)

      expected = {
        test: "eros",
        check: "ered"
      }

      results = TopLevelCheck.new(expected).call(response)
      assert_equal [
        "expected test: 'eros', got 'ers'",
        "expected check: 'ered', got 'mate'"
      ], results
    end

    def test_returns_empty_array_if_response_not_200
      response = stub(response_code: 301, body: "")
      expected = {}
      assert_equal [], TopLevelCheck.new(expected).call(response)
    end

    def test_returns_an_empty_array_if_item_is_gone
      response = stub(response_code: 200, body: {
        schema_name: "gone"
      }.to_json)
      expected = {}
      assert_equal [], TopLevelCheck.new(expected).call(response)
    end
  end
end
