require 'plek'
require 'gds_api/router'

# FIXME: This worker is deprecated, and should be removed once the sidekiq queue has cleared
class RouterAddRouteWorker
  include Sidekiq::Worker
  sidekiq_options queue: :router

  def perform(url_path, options={})
    router_api = GdsApi::Router.new(Plek.current.find('router-api'))
    router_api.add_route(url_path, "exact", "whitehall-frontend")
  end
end
