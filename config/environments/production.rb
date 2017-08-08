Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned off
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Enable JSON-style logging
  config.logstasher.enabled = true
  config.logstasher.logger = Logger.new("#{Rails.root}/log/#{Rails.env}.json.log")
  config.logstasher.suppress_app_log = true

  # Defaults to a file named manifest-<random>.json in the config.assets.prefix
  # directory within the public folder.
  config.assets.manifest = Rails.root.join("public/government/assets/assets-manifest.json")

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Default production log level in Rails 5 will be :debug
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use memcache store in production
  config.cache_store = :dalli_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = Whitehall.asset_root

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # This is not enabled because parts of the publishing pipeline
  # are not threadsafe. Once we've removed instances of `I18n.with_locale`
  # from the codebase, we will be able to enable this if desired.
  # config.threadsafe!

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Send emails via SMTP if SMTP_PORT is set, otherwise send via SES
  # This is mainly used for sending emails to MailHog in the training
  # environment
  if ENV['SMTP_PORT']
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      port: ENV['SMTP_PORT']
    }
  else
    config.action_mailer.delivery_method = :ses
  end
end
