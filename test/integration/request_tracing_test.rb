require "test_helper"

class RequestTracingTest < ActionDispatch::IntegrationTest
  include TaxonomyHelper

  setup do
    @sidekiq_test_mode = Sidekiq::Testing.__test_mode
    Sidekiq::Testing.inline!

    @govuk_request_id = "12345-67890"
    @draft_edition = create(:draft_publication)
    @presenter = PublishingApiPresenters.presenter_for(@draft_edition)
    login_as(create(:gds_admin))
  end

  teardown do
    Sidekiq::Testing.__test_mode = @sidekiq_test_mode
  end

  def force_publish(edition, headers = {})
    post "/government/admin/editions/#{edition.id}/force_publish", params: {
      reason: "Test",
      lock_version: 0,
    }, headers: headers
    follow_redirect!
  end

  test "govuk_request_id is passed downstream across the worker boundary on publish" do
    inbound_headers = {
      "HTTP_GOVUK_REQUEST_ID" => @govuk_request_id,
    }
    stub_publishing_api_links_with_taxons(@draft_edition.content_id, ["a-taxon-content-id"])

    Sidekiq::Testing.fake! do
      force_publish(@draft_edition, inbound_headers)

      # Simulate each worker running in a separate thread
      worker_classes = Sidekiq::Worker.jobs.map { |job| job["class"] }.uniq.map(&:constantize)
      worker_classes.each do |worker_class|
        while worker_class.jobs.any?
          GdsApi::GovukHeaders.clear_headers
          worker_class.perform_one
          GdsApi::GovukHeaders.clear_headers
        end
      end
    end

    assert_equal 200, response.status, response.body

    onward_headers = {
      "GOVUK-Request-Id" => @govuk_request_id
    }

    # Main document
    content_id = @draft_edition.content_id
    assert_requested(:post, %r|publishing-api.*content/#{content_id}/publish|, headers: onward_headers)

    # HTML attachments
    @draft_edition.html_attachments.each do |html_attachment|
      attachment_content_id = html_attachment.content_id
      assert_requested(:post, %r|publishing-api.*content/#{attachment_content_id}/publish|, headers: onward_headers)
    end
  end

  test "govuk_request_id is not passed downstream if the job pre-dates request tracing (e.g. scheduled publishing jobs)" do
    Sidekiq::Testing.fake! do
      PublishingApiWorker.perform_async(@draft_edition.class.name, @draft_edition.id)
      PublishingApiWorker.jobs.first["args"].delete("request_id" => nil)

      GdsApi::GovukHeaders.set_header(:govuk_request_id, @govuk_request_id)
      PublishingApiWorker.perform_one
    end

    content_id = @draft_edition.content_id

    assert_requested(:put, %r|publishing-api.*content/#{content_id}|) do |request|
      assert !request.headers.key?("Govuk-Request-Id")
    end

    assert_requested(:post, %r|publishing-api.*content/#{content_id}/publish|) do |request|
      assert !request.headers.key?("Govuk-Request-Id")
    end

    assert_requested(:patch, %r|publishing-api.*links/#{content_id}|) do |request|
      assert !request.headers.key?("Govuk-Request-Id")
    end
  end
end
