require "gds_api/test_helpers/link_checker_api"

module LinkCheckerApiHelper
  include GdsApi::TestHelpers::LinkCheckerApi

  def link_checker_api_stub_create_batch(response_hash)
    link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"

    body = link_checker_api_batch_report_hash(response_hash).to_json
    status = response_hash[:status].to_s == "in_progress" ? 202 : 201

    stub_request(:post, %r{\A#{link_checker_endpoint}})
      .to_return(
        body: body,
        status: status,
        headers: { "Content-Type": "application/json"},
      )
  end

  def link_checker_api_call_webhook(batch_report_hash)
    body = link_checker_api_batch_report_hash(batch_report_hash)

    header "X-LinkCheckerApi-Signature", generate_signature(body.to_json, Rails.application.secrets.link_checker_api_secret_token)
    header "Content-Type", "application/json"

    post "/government/admin/link-checker-api-callback", body.to_json
  end

  private

  def generate_signature(body, key)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), key, body)
  end
end

World(LinkCheckerApiHelper)
