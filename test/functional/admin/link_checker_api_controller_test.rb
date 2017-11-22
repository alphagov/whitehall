require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class Admin::LinkCheckerApiControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  def generate_signature(body, key)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), key, body)
  end

  setup do
    @link = "http://www.example.com"
    publication = create(:publication, body: "[link](#{@link})")

    report = link_checker_api_batch_report_hash(
      id: 5,
      links: [{ uri: @link }],
    ).with_indifferent_access

    LinkCheckerApiReport.create_from_batch_report(report, publication)
  end

  test "POST :callback updates LinkCheckerApiReport" do
    body = link_checker_api_batch_report_hash(
      id: 5,
      links: [
        { uri: @link, status: "ok" },
      ]
    )
    headers = {
      "Content-Type": "application/json",
      "X-LinkCheckerApi-Signature": generate_signature(body.to_json, Rails.application.secrets.link_checker_api_secret_token)
    }

    request.headers.merge! headers
    post :callback, params: body

    assert_response :success
  end
end
