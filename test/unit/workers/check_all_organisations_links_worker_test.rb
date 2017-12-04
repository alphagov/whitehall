require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class CheckAllOrganisationsLinksWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  enable_url_helpers

  setup do
    hmrc = create(:organisation, name: "HM Revenue & Customs")
    dft = create(:organisation, name: "DfT")

    create(:published_publication,
            lead_organisations: [hmrc],
            body: "[A broken page](https://www.gov.uk/bad-link)\n[A good link](https://www.gov.uk/another-good-link)")

    create(:published_publication,
            lead_organisations: [dft],
            body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)")

    @link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"
  end

  test "calls LinkCheckerApiService with all editions" do
    stub_published_publication
    stub_news_article

    CheckAllOrganisationsLinksWorker.new.perform

    assert_equal 2, LinkCheckerApiReport.count
  end

private

  def stub_news_article
    links = [
      { uri: "https://www.gov.uk/good-link" },
      { uri: "https://www.gov.uk/missing-link" }
    ]

    body = link_checker_api_batch_report_hash(id: 5, links: links)

    stub_request(:post, %r{\A#{@link_checker_endpoint}})
      .with(body: request_body(links))
      .to_return(response_body(body))
  end

  def stub_published_publication
    links = [
      { uri: "https://www.gov.uk/bad-link" },
      { uri: "https://www.gov.uk/another-good-link" }
    ]

    body = link_checker_api_batch_report_hash(id: 6, links: links)

    stub_request(:post, %r{\A#{@link_checker_endpoint}})
      .with(body: request_body(links))
      .to_return(response_body(body))
  end

  def request_body(links)
    uris = links.map { |link| link[:uri] }

    {
      uris: uris,
      webhook_uri: admin_link_checker_api_callback_url(host: Plek.find('whitehall-admin')),
      webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token
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
