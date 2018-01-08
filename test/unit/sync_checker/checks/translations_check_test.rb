require 'maxitest/autorun'
require 'mocha/setup'
require 'active_support'
require 'active_support/json'
require 'active_support/core_ext'
require_relative '../../../../lib/sync_checker/checks/translations_check'

class TranslationsCheckTest < Minitest::Test
  def test_returns_an_empty_array_if_the_translations_match
    response = stub(
      response_code: 200,
      body: {
        links: {
          available_translations: [
            {
              locale: "en",
            },
            {
              locale: "fr",
            }
          ]
        }
      }.to_json
    )

    expected = %w(en fr)

    assert_equal [], SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_returns_an_empty_array_if_the_response_is_not_200
    response = stub(
      response_code: 404,
      body: {
      }.to_json
    )

    expected = %w(en fr)
    assert_equal [], SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  #there is currently a Publishing API bug that prevents the `available_translations`
  #links being populated on `withdrawn` items. This makes things noisy so we should
  #skip them for now.
  def test_returns_an_empty_array_if_the_item_is_withdrawn
    response = stub(
      response_code: 200,
      body: {
        withdrawn_notice: {
          explanation: "blahdy blah"
        }
      }.to_json
    )

    expected = %w(en fr)
    assert_equal [], SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_returns_an_array_of_error_messages_if_there_are_missing_translations
    response = stub(
      response_code: 200,
      body: {
        links: {
          available_translations: [
            {
              locale: "en",
            }
          ]
        }
      }.to_json
    )

    expected = %w(en fr)
    expected_errors = [
      "expected [\"en\", \"fr\"] translations but got [\"en\"]"
    ]

    assert_equal expected_errors, SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_accepts_symbol_expected_locales
    response = stub(
      response_code: 200,
      body: {
        links: {
          available_translations: [
            {
              locale: "en",
            },
            {
              locale: "fr",
            }
          ]
        }
      }.to_json
    )

    expected = %i[en fr]

    assert_equal [], SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_returns_error_if_available_translations_not_present
    response = stub(
      response_code: 200,
      body: {
        links: {}
      }.to_json
    )

    expected = [:en]
    expected_errors = ["available_translations element not present"]

    assert_equal expected_errors, SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_does_not_fail_erroneously_if_locales_are_in_a_different_order
    response = stub(
      response_code: 200,
      body: {
        links: {
          available_translations: [
            {
              locale: "fr",
            },
            {
              locale: "en",
            }
          ]
        }
      }.to_json
    )

    expected = %i[en fr]
    expected_errors = []

    assert_equal expected_errors, SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_returns_no_errors_if_gone
    response = stub(
      response_code: 200,
      body: {
        schema_name: "gone",
        links: {}
      }.to_json
    )

    expected = [:en]
    expected_errors = []

    assert_equal expected_errors, SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end

  def test_returns_no_errors_if_redirect
    response = stub(
      response_code: 200,
      body: {
        schema_name: "redirect",
        links: {}
      }.to_json
    )

    expected = [:en]
    expected_errors = []

    assert_equal expected_errors, SyncChecker::Checks::TranslationsCheck.new(expected).call(response)
  end
end
