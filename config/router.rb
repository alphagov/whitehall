require "router"

router = Router.new("http://router.cluster:8080/router", Rails.logger)
begin
  router.application("whitehall", Plek.current.find("whitehall")) do |app|
    app.ensure_prefix_route Whitehall.router_prefix
    VanityRedirector.new(Rails.root.join("app", "data", "vanity-redirects.csv")).each do |r, _|
      app.ensure_full_route r
      app.ensure_full_route r.upcase
    end
  end
rescue Router::Conflict => conflict_error
  Rails.logger.error "Route already exists: #{conflict_error.existing}"
  raise conflict_error
rescue Router::RemoteError => remote_error
  Rails.logger.error "Remote error response: #{remote_error.response}"
  raise remote_error
end
