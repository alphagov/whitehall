Rummageable.rummager_service_name = "whitehall-search"
Rummageable.path_prefix = Whitehall.router_prefix
Rummageable.rummager_host = ENV["RUMMAGER_HOST"] if ENV["RUMMAGER_HOST"]

Whitehall::SearchClient.search_uri = Rummageable.rummager_host + Whitehall.router_prefix + "/search"

if Rails.env.development?
  Rummageable.implementation = Rummageable::Fake.new
end
