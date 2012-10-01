require 'gds_api/rummager'

Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall.government_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + Whitehall.government_search_index_name)
Whitehall.detailed_guidance_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + Whitehall.detailed_guidance_search_index_name)
Whitehall.mainstream_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + Whitehall.mainstream_search_index_name)

unless Rails.env.production? || ENV["RUMMAGER_HOST"]
  Rummageable.implementation = Rummageable::Fake.new
end
