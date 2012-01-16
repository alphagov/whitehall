Rummageable.rummager_service_name = "whitehall-search"
Rummageable.path_prefix = Whitehall.router_prefix
Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall::SearchClient.search_uri = Rummageable.rummager_host + Whitehall.router_prefix + "/search"

unless Rails.env.production?
  Rummageable.implementation = Rummageable::Fake.new
end
