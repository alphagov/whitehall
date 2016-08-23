require "minitest/autorun"
require "mocha/setup"
require "active_support"
require "active_support/json"
require "active_support/core_ext"
require_relative "../../../lib/sync_checker/links_check"

class LinksCheckTest < Minitest::Test
  def test_it_returns_an_empty_array_for_non_200_responses
    response = stub(
      response_code: 410
    )

    expected_content_ids = [
      "ABC1"
    ]

    assert_equal [], SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end

  def test_it_returns_an_empty_array_for_gone
    response = stub(
      response_code: 200,
      body: {
        schema_name: "gone"
      }.to_json
    )

    expected_content_ids = [
      "ABC1"
    ]

    assert_equal [], SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end

  def test_it_returns_an_error_message_for_each_missing_content_id
    response = stub(
      response_code: 200,
      body: {
        links: {
          lead_organisations: [
            {
              content_id: "ABC1"
            },
          ]
        }
      }.to_json
    )

    expected_content_ids = %w(ABC1 ABC2 ABC3)

    expected_errors = [
      "lead_organisations should contain 'ABC2' but doesn't",
      "lead_organisations should contain 'ABC3' but doesn't",
    ]

    assert_equal expected_errors, SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end

  def test_it_returns_an_error_message_for_each_unexpected_content_id
    response = stub(
      response_code: 200,
      body: {
        links: {
          lead_organisations: [
            {
              content_id: "ABC1"
            },
            {
              content_id: "ABC2"
            },
            {
              content_id: "ABC3"
            },
          ]
        }
      }.to_json
    )

    expected_content_ids = [
      "ABC1",
    ]

    expected_errors = [
      "lead_organisations shouldn't contain 'ABC2'",
      "lead_organisations shouldn't contain 'ABC3'",
    ]

    assert_equal expected_errors, SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end

  def test_it_returns_an_error_if_the_key_not_present
    response = stub(
      response_code: 200,
      body: {
        links: {}
      }.to_json
    )

    expected_content_ids = [
      "ABC1",
    ]

    expected_errors = [
      "the links key 'lead_organisations' is not present"
    ]

    assert_equal expected_errors, SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end

  def test_it_returns_an_empty_array_if_there_are_no_expected_content_ids
    response = stub(
      response_code: 200,
      body: {
        links: {}
      }.to_json
    )

    expected_content_ids = []

    expected_errors = []

    assert_equal expected_errors, SyncChecker::LinksCheck.new(
      "lead_organisations",
      expected_content_ids
    ).call(response)
  end
end
