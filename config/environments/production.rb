require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned off.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = false

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  config.public_file_server.enabled = true

  # Compress JavaScripts and CSS.
  # Can also use `Terser.new(mangle: false)` to disable name mangling
  config.assets.js_compressor = :terser

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to a file named manifest-<random>.json in the config.assets.prefix
  # directory within the public folder.
  config.assets.manifest = Rails.root.join("public/assets/whitehall/assets-manifest.json")
  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for nginx
  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Log to STDOUT by default
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::Logger.new($stdout)
                                         .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
                                         .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  end

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Prefix memcache keys to avoid name clashes when sharing a cache.
  config.cache_store = :mem_cache_store, nil, { namespace: ENV.fetch("MEMCACHE_KEY_PREFIX", "whitehall"), compress: true }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "whitehall_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Send emails via SMTP if SMTP_PORT is set, otherwise send via SES
  # This is mainly used for sending emails to MailHog in the dev VM
  if ENV["SMTP_PORT"]
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      port: ENV["SMTP_PORT"],
    }
  else
    config.action_mailer.delivery_method = :notify
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    /whitehall-admin\..*\.gov.uk$/,
    /^link-checker-api$/,
  ]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path.match?("^\/healthcheck") } }
end
