Whitehall::Application.config.slimmer.logger = Rails.logger
if Rails.env.development?
  # XXX: This needs to specifically be inserted here, as the NewRelic
  # middleware comes after Slimmer, but we need to run before that,
  # but after Slimmer. Otherwise Slimmer won't pick up our header.
  Whitehall::Application.config.middleware.insert_after Slimmer::App, Whitehall::NewRelicDeveloperMode
end
