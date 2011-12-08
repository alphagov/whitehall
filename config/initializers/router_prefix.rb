Whitehall::Application.config.middleware.use Whitehall::SkipSlimmer if Rails.env.test?
Whitehall::Application.config.middleware.use Whitehall::RedirectToRouterPrefix
