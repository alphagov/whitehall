require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class RevalidateOldLinkCheckReportsWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  enable_url_helpers

  test "given a number of public editions, it requests link checks for the least recently checked editions, up to the MAX_REPORTS_TO_CHECK maximum" do
    links = [{ uri: "https://www.gov.uk/some-link" }]
    publication_with_newest_report = create_published_publication(links)
    create(:link_checker_api_report_completed, batch_id: 3, edition: publication_with_newest_report, updated_at: 1.week.ago)
    update_publication_with_newest_report = stub_post_request(links, link_checker_api_batch_report_hash(id: 3, links:))

    links = [{ uri: "https://www.gov.uk/some-other-link" }]
    publication_with_old_report = create_published_publication(links)
    create(:link_checker_api_report_completed, batch_id: 2, edition: publication_with_old_report, updated_at: 2.weeks.ago)
    update_publication_with_old_report = stub_post_request(links, link_checker_api_batch_report_hash(id: 2, links:))

    links = [{ uri: "https://www.gov.uk/some-other-link-again" }]
    publication_with_oldest_report = create_published_publication(links)
    create(:link_checker_api_report_completed, batch_id: 1, edition: publication_with_oldest_report, updated_at: 3.weeks.ago)
    update_publication_with_oldest_report = stub_post_request(links, link_checker_api_batch_report_hash(id: 1, links:))

    RevalidateOldLinkCheckReportsWorker.stub_const(:MAX_REPORTS_TO_CHECK, 2) do
      Sidekiq.logger.stub(:info, nil) do
        RevalidateOldLinkCheckReportsWorker.new.perform
        RevalidateLinkCheckReportWorker.drain
      end

      assert_requested update_publication_with_oldest_report
      assert_requested update_publication_with_old_report
      assert_not_requested update_publication_with_newest_report
    end
  end

  test "doesn't make a Link Checker API request if edition contains no links" do
    links = []
    publication = create_published_publication(links)
    create(:link_checker_api_report_completed, batch_id: nil, edition: publication, links:, updated_at: 1.week.ago)

    LinkCheckerApiService.expects(:check_links).never

    Sidekiq.logger.stub(:info, nil) do
      RevalidateOldLinkCheckReportsWorker.new.perform
      RevalidateLinkCheckReportWorker.drain
    end
  end

private

  def create_published_publication(links)
    link_str = links.map { |link| "[a link](#{link[:uri]})" }.join(" ")
    create(
      :published_publication,
      body: "Links: #{link_str}",
    )
  end

  def stub_post_request(links, body)
    link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"
    stub_request(:post, %r{\A#{link_checker_endpoint}})
      .with(body: request_body(links))
      .to_return(response_body(body))
  end

  def request_body(links)
    uris = links.map { |link| link[:uri] }

    {
      uris:,
      webhook_uri: admin_link_checker_api_callback_url(host: Plek.find("whitehall-admin")),
      webhook_secret_token: Rails.application.credentials.link_checker_api_secret_token,
    }
  end

  def response_body(body)
    {
      body: body.to_json,
      status: 202,
      headers: { "Content-Type": "application/json" },
    }
  end
end
