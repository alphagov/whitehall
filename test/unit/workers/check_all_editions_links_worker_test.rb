require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class CheckAllEditionsLinksWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  enable_url_helpers

  setup do
    @hmrc = create(:organisation, name: "HM Revenue & Customs")
    embassy_paris = create(:worldwide_organisation, name: "British Embassy Paris")

    @published_publication = create(:published_publication,
                                    lead_organisations: [@hmrc],
                                    body: "[A broken page](https://www.gov.uk/bad-link)\n[A good link](https://www.gov.uk/another-good-link)")

    @news_article = create(:world_location_news_article,
                            :withdrawn,
                            worldwide_organisations: [embassy_paris],
                            body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)")

    @link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"
  end

  test "calls LinkCheckerApiService with all editions" do
    stub_published_publication
    stub_news_article

    CheckAllEditionsLinksWorker.new.perform

    assert_equal 2, LinkCheckerApiReport.count
  end

  test "when given an organisation it only calls LinkCheckerApiService with editions for that organisation" do
    stub_published_publication

    CheckAllEditionsLinksWorker.new.perform(@hmrc.id)

    assert_equal 1, LinkCheckerApiReport.count
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
      webhook_uri: admin_link_checker_api_callback_url,
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
