require 'gds_api/rummager'

Rummageable.rummager_service_name = "whitehall-search"
Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall.government_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + Whitehall.government_search_index_name)
Whitehall.detailed_guidance_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + Whitehall.detailed_guidance_search_index_name)

# We're still using two Rummager instances until Mainstream is upgraded, at which point we can
# connect to a single instance that provides access to multiple indexes.
mainstream_rummager_service_name = 'search'
mainstream_rummager_host = Plek.current.find(mainstream_rummager_service_name)
Whitehall.mainstream_search_client = GdsApi::Rummager.new(mainstream_rummager_host)

unless Rails.env.production? || ENV["RUMMAGER_HOST"]
  Rummageable.implementation = Rummageable::Fake.new
end
