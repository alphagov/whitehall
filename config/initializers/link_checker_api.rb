require "gds_api/link_checker_api"

Whitehall.link_checker_api_client = GdsApi::LinkCheckerApi.new(
  Plek.find("link-checker-api")
)
