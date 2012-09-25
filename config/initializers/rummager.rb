require 'gds_api/rummager'

Rummageable.rummager_service_name = "whitehall-search"
Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall.government_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + '/government')
Whitehall.specialist_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + '/specialist')
Whitehall.mainstream_search_client = GdsApi::Rummager.new(Rummageable.rummager_host + '')

unless Rails.env.production? || ENV["RUMMAGER_HOST"]
  Rummageable.implementation = Rummageable::Fake.new
end