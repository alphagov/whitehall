require "gds_api/link_checker_api"

Whitehall.link_checker_api_client = GdsApi::LinkCheckerApi.new(
  Plek.find("link-checker-api"),
  bearer_token: ENV["LINK_CHECKER_API_BEARER_TOKEN"] || "example"
)