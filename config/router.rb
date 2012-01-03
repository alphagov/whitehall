require "router"

router = Router.new("http://router.cluster:8080/router", Rails.logger)
begin
  router.application("whitehall", Plek.current.find("whitehall").gsub(/https/, "http")) do |app|
    app.ensure_prefix_route Whitehall.router_prefix
  end
rescue Router::Conflict => conflict_error
  Rails.logger.error "Route already exists: #{conflict_error.existing}"
  raise conflict_error
rescue Router::RemoteError => remote_error
  Rails.logger.error "Remote error response: #{remote_error.response}"
  raise remote_error
end
