Rummageable.rummager_service_name = "whitehall-search"
Rummageable.path_prefix = Whitehall.router_prefix
Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall.search_client = Whitehall::SearchClient.new(Rummageable.rummager_host + Whitehall.router_prefix)

unless Rails.env.production? || ENV["RUMMAGER_HOST"]
  Rummageable.implementation = Rummageable::Fake.new
end
