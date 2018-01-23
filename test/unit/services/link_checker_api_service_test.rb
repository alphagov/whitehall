require 'test_helper'

class LinkCheckerApiServiceTest < ActiveSupport::TestCase
  WEBHOOK_URI = "https://example.com/webhook_uri".freeze
  LINK_CHECKER_RESPONSE = { id: 123, completed_at: nil, status: "completed" }.to_json.freeze

  test "checks external URL" do
    edition = Edition.new(body: "A doc with a link to [an external URL](https://example.com/some-page)")

    link_check_request = stub_request(:post, "https://link-checker-api.test.gov.uk/batch").
      with(body: /https:\/\/example\.com\/webhook_uri/).
      to_return(status: 200, body: LINK_CHECKER_RESPONSE)

    LinkCheckerApiService.check_links(edition, WEBHOOK_URI)

    assert_requested(link_check_request)
  end

  test "checks internal URL" do
    edition = Edition.new(body: "A doc with a link to [an internal URL](/bank-holidays)")

    link_check_request = stub_request(:post, "https://link-checker-api.test.gov.uk/batch").
      with(body: /\/bank-holidays/).
      to_return(status: 200, body: LINK_CHECKER_RESPONSE)

    LinkCheckerApiService.check_links(edition, WEBHOOK_URI)

    assert_requested(link_check_request)
  end

  test "raises error if there are no URLs in the document" do
    edition = Edition.new(body: "Some text")

    assert_raises "Reportable has no links to check" do
      LinkCheckerApiService.check_links(edition, WEBHOOK_URI)
    end
  end
end
