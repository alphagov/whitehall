require 'gds_api/rummager'

Whitehall.government_search_client = GdsApi::Rummager.new(
    Whitehall::SearchIndex.rummager_host + Whitehall.government_search_index_path)
