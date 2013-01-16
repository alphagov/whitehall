Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned off
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable even limited exception/debug pages in production for two reasons:
  #  1) our backend rails apps get X-Forwarded-For & Client-IP for all requests
  #     as 10.x.x.x, which is a trusted proxy. This means they render the
  #     limited exception/debug pages.
  #  2) our backend rails apps receive requests from other apps that might
  #     appear to be on trusted proxy IPs, so we might render exception/debug
  #     page, which could then be exposed in a frontend app to the world.
  config.action_dispatch.show_exceptions = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Enable lograge
  config.lograge.enabled = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = Whitehall.asset_host

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w(
    admin.css
    admin-ie8.css
    admin-ie7.css
    admin-ie6.css
    frontend/base.css
    frontend/base-ie8.css
    frontend/base-ie7.css
    frontend/base-ie6.css
    frontend/print.css
    admin.js
  )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :ses

  config.slimmer.use_cache = true
end
