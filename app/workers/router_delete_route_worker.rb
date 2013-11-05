require 'plek'
require 'gds_api/router'

class RouterDeleteRouteWorker
  include Sidekiq::Worker
  sidekiq_options queue: :router

  def perform(url_path, options={})
    router_api = GdsApi::Router.new(Plek.current.find('router-api'))
    # If the route has never been created, this will 404. We
    # should handle this as the end result is the same either way
    # - the route won't work.
    begin
      router_api.delete_route(url_path, "exact", "whitehall-frontend")
    rescue GdsApi::HTTPNotFound
      nil
    end
  end
end
