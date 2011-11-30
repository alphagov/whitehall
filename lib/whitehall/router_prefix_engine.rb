module Whitehall
  class RouterPrefixEngine < ::Rails::Engine
    initializer "whitehall.router.prefix", before: "sprockets.environment" do |app|
      app.config.assets.prefix = Whitehall.router_prefix + app.config.assets.prefix
      app.config.middleware.use Whitehall::RedirectToRouterPrefix
    end
  end
end