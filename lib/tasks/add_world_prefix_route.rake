require 'gds_api/router'

namespace :router do
  desc 'Add the /world prefix route to the router to send all requests to whitehall'
  task add_world_prefix_route: :environment do
    router = GdsApi::Router.new(Plek.find('router-api'))
    router.add_route('/world', 'prefix', 'whitehall-frontend')
    router.commit_routes
  end
end
