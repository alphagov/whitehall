require 'minitest/autorun'
require 'mocha/setup'
require 'active_support'
require 'active_support/json'
require 'active_support/core_ext'

require_relative '../../../lib/sync_checker/checks/details_check'

module SyncChecker::Checks
  class DetailsCheckTest < Minitest::Test
    def test_non_200_returns_an_empty_array
      response = stub(
        response_code: 404,
        body: {
        }.to_json
      )

      expected = {
        body: "a bit of html"
      }

      assert_equal [], DetailsCheck.new(expected).call(response)
    end

    def test_gone_returns_an_empty_array
      response = stub(
        response_code: 200,
        body: {
          schema_name: "gone"
        }.to_json
      )

      expected = {
        body: "a bit of html"
      }

      assert_equal [], DetailsCheck.new(expected).call(response)
    end

    def test_incorrect_body_returns_an_error
      response = stub(
        response_code: 200,
        body: {
          details: {
            body: "the wrong html"
          }
        }.to_json
      )

      expected = {
        body: "a bit of html"
      }

      expected_errors = [
        "details body doesn't match"
      ]

      assert_equal expected_errors, DetailsCheck.new(expected).call(response)
    end

    def test_correct_body_returns_no_errors
      response = stub(
        response_code: 200,
        body: {
          details: {
            body: "the right html"
          }
        }.to_json
      )

      expected = {
        body: "the right html"
      }

      assert_equal [], DetailsCheck.new(expected).call(response)
    end

    def test_html_equivalence_passes
      response = stub(
        response_code: 200,
        body: {
          details: {
            body: "<h1>the right html</h1>"
          }
        }.to_json
      )

      expected = {
        body: <<-HTML
        <h1>
          the right html
        </h1>
        HTML
      }

      assert_equal [], DetailsCheck.new(expected).call(response)
    end

    def test_the_other_fields_return_errors_if_they_dont_match
      response = stub(
        response_code: 200,
        body: {
          details: {
            test_one: 1,
            test_two: 2
          }
        }.to_json
      )

      expected = {
        test_one: "one",
        test_two: "two",
      }

      expected_errors = [
        "expected details 'test_one' to equal 'one' but got '1'",
        "expected details 'test_two' to equal 'two' but got '2'",
      ]

      assert_equal expected_errors, DetailsCheck.new(expected).call(response)
    end

    def test_an_error_is_returned_if_a_supplied_field_is_missing
      response = stub(
        response_code: 200,
        body: {
          details: {
            test_one: "one",
          }
        }.to_json
      )

      expected = {
        test_one: "one",
        test_two: "two",
      }

      expected_errors = [
        "expected details to contain 'test_two' == 'two'",
      ]

      assert_equal expected_errors, DetailsCheck.new(expected).call(response)
    end
  end
end
