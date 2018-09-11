require "maxitest/autorun"
require "mocha/setup"
require "active_support"
require "active_support/json"
require "active_support/core_ext"

require_relative "../../../../lib/sync_checker/checks/topics_check"

module SyncChecker
  module Checks
    class TopicsCheckTest < Minitest::Test
      def test_it_returns_no_errors_if_response_not_200
        edition = stub(specialist_sector_tags: [])
        response = stub(
          response_code: 404
        )
        assert_equal [], TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_errors_if_response_gone
        edition = stub(specialist_sector_tags: ["/booyah"])
        response = stub(
          response_code: 200,
          body: {
            schema_name: "gone"
          }.to_json
        )
        assert_equal [], TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_errors_if_response_redirect
        edition = stub(specialist_sector_tags: ["/booyah"])
        response = stub(
          response_code: 200,
          body: {
            schema_name: "redirect"
          }.to_json
        )
        assert_equal [], TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_parent_is_incorrect
        tag = "ABC-CORRECT-CONTENT-ID"
        edition = stub(
          specialist_sector_tags: [tag],
          primary_specialist_sector_tag: tag,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              parent: [
                {
                  content_id: "XYZ-WRONG-CONTENT-ID"
                }
              ],
              topics: [
                {
                  content_id: "ABC-CORRECT-CONTENT-ID"
                }
              ]
            }
          }.to_json
        )

        expected_errors = ["expected parent#content_id to be 'ABC-CORRECT-CONTENT-ID' but got 'XYZ-WRONG-CONTENT-ID'"]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_error_if_parent_is_correct
        tag = "ABC-CORRECT-CONTENT-ID"
        edition = stub(
          specialist_sector_tags: [tag],
          primary_specialist_sector_tag: tag,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              parent: [
                {
                  content_id: "ABC-CORRECT-CONTENT-ID"
                }
              ],
              topics: [
                {
                  content_id: "ABC-CORRECT-CONTENT-ID"
                }
              ]
            }
          }.to_json
        )

        expected_errors = []

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_error_if_there_is_no_parent_and_no_primary_specialist_sector
        edition = stub(
          specialist_sector_tags: [],
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
            }
          }.to_json
        )

        expected_errors = []

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_parent_isnt_present_but_should_be
        tag = "ABC-CORRECT-CONTENT-ID"
        edition = stub(
          specialist_sector_tags: [],
          primary_specialist_sector_tag: tag,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
            }
          }.to_json
        )

        expected_errors = ["expected links#parent but it isn't present"]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_parent_is_present_but_shouldnt_be
        edition = stub(
          specialist_sector_tags: [],
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              parent: [
                {
                  content_id: "BOOYAH"
                }
              ]
            }
          }.to_json
        )

        expected_errors = ["links#parent is present but shouldn't be"]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_errors_if_topics_are_appropriately_absent
        edition = stub(
          specialist_sector_tags: [],
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
            }
          }.to_json
        )

        expected_errors = []

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_topics_is_present_and_shouldnt_be
        edition = stub(
          specialist_sector_tags: [],
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              topics: [
                {
                  content_id: "TOPIC_CONTENT_ID"
                }
              ]
            }
          }.to_json
        )

        expected_errors = ["links#topics are present but shouldn't be"]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_there_are_no_topics_but_there_should_be
        tag = "test/tag"
        edition = stub(
          specialist_sector_tags: [tag],
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
            }
          }.to_json
        )

        expected_errors = ["expected links#topics but it isn't present"]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_errors_if_the_topics_are_correct
        tags = %w(CORRECT_TOPIC_ID_ONE CORRECT_TOPIC_ID_TWO)
        edition = stub(
          specialist_sector_tags: tags,
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              topics: [
                {
                  content_id: "CORRECT_TOPIC_ID_ONE"
                },
                {
                  content_id: "CORRECT_TOPIC_ID_TWO"
                }
              ]
            }
          }.to_json
        )

        expected_errors = []

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_there_are_missing_topics
        tags = %w(MISSING_TOPIC_ID_ONE MISSING_TOPIC_ID_TWO)
        edition = stub(
          specialist_sector_tags: tags,
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              topics: []
            }
          }.to_json
        )

        expected_errors = [
          "links#topics should contain 'MISSING_TOPIC_ID_ONE' but doesn't",
          "links#topics should contain 'MISSING_TOPIC_ID_TWO' but doesn't"
        ]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_an_error_if_there_are_unexpected_topics
        tags = %w[CORRECT_TOPIC_ID_ONE]
        edition = stub(
          specialist_sector_tags: tags,
          primary_specialist_sector_tag: nil,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              topics: [
                {
                  content_id: "CORRECT_TOPIC_ID_ONE"
                },
                {
                  content_id: "UNEXPECTED_TOPIC_ID"
                }
              ]
            }
          }.to_json
        )

        expected_errors = [
          "links#topics contains 'UNEXPECTED_TOPIC_ID' but shouldn't",
        ]

        assert_equal expected_errors, TopicsCheck.new(edition).call(response)
      end

      def test_it_returns_no_errors_when_draft_topics_are_not_present_in_the_response
        tag = 'ABC-CORRECT-CONTENT-ID'
        draft_tag = 'XYZ-CORRECT-CONTENT-ID'

        edition = stub(
          specialist_sector_tags: [tag, draft_tag],
          primary_specialist_sector_tag: tag,
        )

        response = stub(
          response_code: 200,
          body: {
            links: {
              parent: [
                {
                  content_id: 'ABC-CORRECT-CONTENT-ID'
                }
              ],
              topics: [
                {
                  content_id: 'ABC-CORRECT-CONTENT-ID'
                }
              ]
            }
          }.to_json
        )

        topics_check = TopicsCheck.new(edition, topic_blacklist: ['XYZ-CORRECT-CONTENT-ID'])

        assert_empty topics_check.call(response)
      end
    end
  end
end
