require 'minitest/autorun'
require 'mocha/setup'
require 'active_support/json'
require_relative '../../../../lib/sync_checker/checks/http_status_check'

module SyncChecker::Checks
  class HttpStatusCheckTest < Minitest::Test
    def response(response_code)
      response_request = stub(base_url: "/government/base/url")

      stub(
        response_code: response_code,
        request: response_request
      )
    end

    def test_returns_failure_results_with_single_disallowed_response_code_and_the_same_actual_response_code
      results = HttpStatusCheck.new(404).call(response(404))

      refute_empty results
    end

    def test_returns_failure_results_with_range_of_disallowed_response_codes_and_actual_response_code_inside_range
      (400..499).each do |http_response|
        results = HttpStatusCheck.new(400..499).call(response(http_response))

        refute_empty results
      end
    end

    def test_returns_no_failure_results_with_single_disallowed_response_code_and_different_actual_response_code
      results = HttpStatusCheck.new(404).call(response(200))

      assert_empty results
    end

    def test_returns_no_failure_results_with_range_of_disallowed_response_codes_and_actual_response_code_outside_range
      results = HttpStatusCheck.new(400..499).call(response(200))

      assert_empty results
    end
  end
end
