require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class CheckOrganisationLinksWorkerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  enable_url_helpers

  setup do
    @hmrc = create(:organisation, name: "HM Revenue & Customs")
    embassy_paris = create(:worldwide_organisation, name: "British Embassy Paris")

    create(:published_publication,
           lead_organisations: [@hmrc],
           body: "[A broken page](https://www.gov.uk/bad-link)\n[A good link](https://www.gov.uk/another-good-link)")

    create(:world_location_news_article,
           :withdrawn,
           worldwide_organisations: [embassy_paris],
           body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)")

    @link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"
  end

  test "when given an organisation it only calls LinkCheckerApiService with editions for that organisation" do
    new_edition = stub_published_publication

    CheckOrganisationLinksWorker.new.perform(@hmrc.id)

    assert_equal 1, LinkCheckerApiReport.count
    assert_requested new_edition
  end

  test "when an organisation contains more new editions than the limit" do
    new_edition = stub_published_publication
    existing_edition = create_and_stub_an_edition_with_checks(@hmrc)
    another_existing_edition = create_and_stub_an_edition(@hmrc)

    assert_report_count_increased

    assert_requested new_edition
    assert_requested another_existing_edition
    assert_not_requested existing_edition
  end

  test "when an organisation contains new and old editions" do
    new_edition = stub_published_publication
    existing_edition = create_and_stub_an_edition_with_checks(@hmrc)

    assert_report_count_increased

    assert_requested new_edition
    assert_requested existing_edition
  end

  test "when an organisation contains new and multiple old editions the one with the oldest check will be sent to be checked" do
    new_edition = stub_published_publication
    existing_edition = create_and_stub_an_edition_with_checks(@hmrc)
    another_existing_edition = create_and_stub_edition_with_historic_checks(@hmrc)

    assert_report_count_increased

    assert_requested new_edition
    assert_requested another_existing_edition
    assert_not_requested existing_edition
  end

private

  def assert_report_count_increased
    stub_organisation_edition_limit(2) do
      assert_difference 'LinkCheckerApiReport.count', 2 do
        CheckOrganisationLinksWorker.new.perform(@hmrc.id)
      end
    end
  end

  def stub_published_publication
    links = [
      { uri: "https://www.gov.uk/bad-link" },
      { uri: "https://www.gov.uk/another-good-link" }
    ]

    body = link_checker_api_batch_report_hash(id: 6, links: links)

    stub_post_request(links, body)
  end

  def create_and_stub_an_edition(organisation)
    links = [
      { uri: "https://www.gov.uk/very-bad-link" },
      { uri: "https://www.gov.uk/yet-another-good-link" }
    ]

    create_published_publication(organisation, links)

    body = link_checker_api_batch_report_hash(id: 7, links: links)

    stub_post_request(links, body)
  end

  def create_and_stub_an_edition_with_checks(organisation)
    links = [
      { uri: "https://www.gov.uk/very-bad-link-1" },
      { uri: "https://www.gov.uk/yet-another-good-link-1" }
    ]

    publication = create_published_publication(organisation, links)

    create(:link_checker_api_report_completed, link_reportable: publication)

    body = link_checker_api_batch_report_hash(id: 8, links: links)

    stub_post_request(links, body)
  end

  def create_and_stub_edition_with_historic_checks(organisation)
    links = [
      { uri: "https://www.gov.uk/very-old-link" },
      { uri: "https://www.gov.uk/yet-another-old-link" }
    ]

    publication = create_published_publication(organisation, links)

    create(:link_checker_api_report_completed, batch_id: 2, link_reportable: publication, updated_at: 2.weeks.ago)

    body = link_checker_api_batch_report_hash(id: 9, links: links)

    stub_post_request(links, body)
  end

  def stub_organisation_edition_limit(limit)
    CheckOrganisationLinksWorker.stub_const(:ORGANISATION_EDITION_LIMIT, limit) do
      yield
    end
  end

  def stub_post_request(links, body)
    stub_request(:post, %r{\A#{@link_checker_endpoint}})
      .with(body: request_body(links))
      .to_return(response_body(body))
  end

  def create_published_publication(organisation, links)
    create(:published_publication,
           lead_organisations: [organisation],
           body: links.map { |link| "[a link](#{link[:uri]})" }.join(' '))
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
