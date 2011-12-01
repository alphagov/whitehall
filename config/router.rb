require "router"

router = Router.new("http://router.cluster:8080/router", Rails.logger)
router.application("whitehall", Plek.current.find("whitehall")) do |app|
  app.ensure_prefix_route Whitehall.router_prefix
end