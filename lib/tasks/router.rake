require 'logger'

namespace :router do
  task :router_environment => :environment do
    require 'plek'
    require 'gds_api/router'
    @logger = Logger.new STDOUT
    @logger.level = Logger::DEBUG
    @router_api = GdsApi::Router.new(Plek.current.find('router-api'))
    @application_id = "whitehall-frontend"
  end

  desc "Register the whitehall backend with the router"
  task :register_backend => :router_environment do
    @logger.info "Registering application..."
    @router_api.add_backend(@application_id, Plek.current.find('whitehall-frontend', :force_http => true) + "/")
  end

  desc "Register the government prefix with the router"
  task :register_routes => :router_environment do
    @router_api.add_route("/government", "prefix", @application_id)
  end

  desc "Register all detailed guidance categories with the router"
  task :register_detailed_guidance_categories => :register_backend do
    MainstreamCategory.find_each do |category|
      path = "/" + category.path
      @logger.info "Registering detailed guidance category '#{path}'"
      @router_api.add_route(path, "exact", @application_id, skip_commit: true)
    end
    @logger.info "Detailed guidance categories registered, reloading routes..."
    @router_api.commit_routes
  end

  desc "Register all detailed guides with the router"
  task :register_guidance => [:environment, :router_environment, :register_backend, :register_detailed_guidance_categories, :register_unpublished_guidance] do
    DetailedGuide.published.includes(:document).each do |guide|
      path = "/#{guide.slug}"
      @logger.info "Registering detailed guide #{path}..."
      @router_api.add_route(path, "exact", @application_id, skip_commit: true)
    end
    @logger.info "Guides registered, reloading routes..."
    @router_api.commit_routes
  end

  desc "Register all unpublished detailed guides with the router"
  task :register_unpublished_guidance => [:environment, :router_environment, :register_backend] do
    Unpublishing.where(document_type: DetailedGuide.name).each do |unpublishing|
      path = "/#{unpublishing.slug}"
      @logger.info "Registering detailed guide unpublishing #{path}..."
      @router_api.add_route(path, "exact", @application_id, skip_commit: true)
    end
    @logger.info "Guides unpublishings registered, reloading routes..."
    @router_api.commit_routes
  end

  desc "Register whitehall backend and routes with the router"
  task :register => [ :register_backend, :register_routes ]
end
