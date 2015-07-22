require 'logger'

namespace :router do
  task :router_environment => :environment do
    require 'plek'
    require 'gds_api/router'
    @logger = Logger.new STDOUT
    @logger.level = Logger::DEBUG
    @router_api = GdsApi::Router.new(Plek.find('router-api'))
    @application_id = "whitehall-frontend"
  end

  desc "Register the whitehall backend with the router"
  task :register_backend => :router_environment do
    @logger.info "Registering application..."
    @router_api.add_backend(@application_id, Plek.find('whitehall-frontend', :force_http => true) + "/")
  end

  desc "Register the government prefix with the router"
  task :register_routes => :router_environment do
    @router_api.add_route("/government", "prefix", @application_id)
    @router_api.add_route("/courts-tribunals", "prefix", @application_id)
  end

  desc "Register whitehall backend and routes with the router"
  task :register => [ :register_backend, :register_routes ]
end
