Whitehall::Application.config.assets.prefix = Whitehall.router_prefix + Whitehall::Application.config.assets.prefix
Whitehall::Application.config.middleware.use Whitehall::RedirectToRouterPrefix