require "gds_api/test_helpers/link_checker_api"

module LinkCheckerApiHelper
  include GdsApi::TestHelpers::LinkCheckerApi

  def link_checker_api_stub_create_batch(response_hash)
    link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"

    body = link_checker_api_batch_report_hash(response_hash)
    status = response_hash[:status].to_s == "in_progress" ? 202 : 201

    stub_request(:post, %r{\A#{link_checker_endpoint}})
      .to_return(
        body: body.to_json,
        status: status,
        headers: { "Content-Type": "application/json" },
      )
  end

  def link_checker_api_call_webhook(batch_report_hash)
    hash = link_checker_api_batch_report_hash(batch_report_hash)
    post "/government/admin/link_checker_api_callback", hash
  end
end

World(LinkCheckerApiHelper)
