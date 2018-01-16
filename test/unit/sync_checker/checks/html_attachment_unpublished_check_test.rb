require 'equivalent-xml'

require "minitest/autorun"
require "mocha/setup"
require "active_support/json"
require "active_model"

require_relative "../../../../lib/whitehall/govspeak_renderer"
require_relative "../../../../lib/active_record_like_interface"
require_relative "../../../../app/models/unpublishing_reason"
require_relative "../../../../lib/sync_checker/checks/html_attachment_unpublished_check.rb"

module SyncChecker
  module Checks
    class HtmlUnpublishedCheckTest < Minitest::Test
      def setup
        Whitehall::GovspeakRenderer.stubs(:new).returns(@stub_renderer = stub)
      end

      def test_returns_no_errors_if_the_attachable_has_no_unpublishing
        attachment = stub(
          attachable: stub(
            unpublishing: nil,
            "withdrawn?" => false,
            "draft?" => false
          )
        )

        assert_equal [], HtmlAttachmentUnpublishedCheck.new(attachment).call(stub)
      end

      def test_returns_no_errors_if_the_attachable_is_withdrawn_and_the_attachment_has_a_withdrawn_notice
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::WITHDRAWN_ID,
              explanation: "Withdrawnificated"
            ),
            "withdrawn?" => true,
            "draft?" => false
          )
        )

        response = stub(
          body: {
            withdrawn_notice: {
              explanation: "<p>Withdrawnificated</p>"
            }
          }.to_json
        )

        @stub_renderer.stubs(:govspeak_to_html).returns("<p>Withdrawnificated</p>")

        assert_equal [], HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_an_error_if_the_document_should_be_withdrawn_but_has_no_notice
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::WITHDRAWN_ID,
              explanation: "Withdrawnificated"
            ),
            "withdrawn?" => true,
            "draft?" => false
          )
        )

        response = stub(
          body: {
            withdrawn_notice: {}
          }.to_json
        )

        @stub_renderer.stubs(:govspeak_to_html).returns("<p>Withdrawnificated</p>")

        expected_error = "expected withdrawn notice: '<p>Withdrawnificated</p>' but got ''"

        assert_equal [expected_error],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_no_error_if_the_attachable_is_unpublished_in_error_and_the_attachment_returns_a_redirect_to_the_parent
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID,
              explanation: "Unpublished Error",
              alternative_url: "https://gov.uk/alt",
              "redirect?" => false
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          #we can't currently test the destination of a content-store redirect item
          #as it isn't in the JSON
          body: {
            schema_name: "redirect",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        assert_equal [],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_an_error_if_the_attachable_is_unpublished_in_error_and_there_is_no_redirect_to_the_parent
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID,
              explanation: "Unpublished Error",
              alternative_url: "https://gov.uk/alt",
              "redirect?" => false
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          body: {
            schema_name: "gone",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        expected_error = "attachment should redirect to parent"

        assert_equal [expected_error],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_no_error_if_the_attachable_is_unpublished_in_error_and_the_attachment_returns_a_redirect_to_the_alternative_url
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID,
              explanation: "Unpublished Error",
              alternative_url: "https://gov.uk/alt",
              "redirect?" => true
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          body: {
            schema_name: "redirect",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        assert_equal [],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_an_error_if_the_attachable_is_unpublished_in_error_and_the_attachment_does_not_redirect
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::PUBLISHED_IN_ERROR_ID,
              explanation: "Unpublished Error",
              alternative_url: "https://gov.uk/alt",
              "redirect?" => true
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          body: {
            schema_name: "gone",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        expected_error = "attachment should redirect to the 'https://gov.uk/alt'"

        assert_equal [expected_error],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_no_error_if_attachable_consolidated_and_attachment_redirects
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::CONSOLIDATED_ID,
              alternative_url: "https://gov.uk/alt"
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          body: {
            schema_name: "redirect",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        assert_equal [],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end

      def test_returns_an_error_if_attachable_consolidated_and_attachment_does_not_redirect
        attachment = stub(
          attachable: stub(
            unpublishing: stub(
              unpublishing_reason_id: UnpublishingReason::CONSOLIDATED_ID,
              alternative_url: "https://gov.uk/alt"
            ),
            "withdrawn?" => false,
            "draft?" => true
          )
        )

        response = stub(
          body: {
            schema_name: "gone",
            withdrawn_notice: {},
            details: {}
          }.to_json
        )

        expected_error = "attachment should redirect to the 'https://gov.uk/alt'"

        assert_equal [expected_error],
          HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
      end
    end

    def test_returns_an_error_if_there_is_no_item_in_the_content_store
      attachment = stub(
        attachable: stub(
          unpublishing: stub(
            unpublishing_reason_id: UnpublishingReason::CONSOLIDATED_ID,
            alternative_url: "https://gov.uk/alt"
          ),
          "withdrawn?" => false,
          "draft?" => true
        )
      )
      response = stub(
        body: ""
      )

      expected_error = "attachable has been unpublished but the attachment has nothing in the content store"

      assert_equal [expected_error],
        HtmlAttachmentUnpublishedCheck.new(attachment).call(response)
    end
  end
end
