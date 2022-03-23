require "gds_api/search"

Whitehall.government_search_client = GdsApi::Search.new(
  Plek.find("search") + Whitehall::SearchIndex.government_search_index_path,
  bearer_token: ENV["RUMMAGER_BEARER_TOKEN"] || "example",
)

Whitehall.search_client = GdsApi::Search.new(
  Plek.find("search"),
  bearer_token: ENV["RUMMAGER_BEARER_TOKEN"] || "example",
)
