require 'gds_api/gov_uk_delivery'

Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.slimmer.asset_host = ENV['GOVUK_ASSET_ROOT'] || "https://static.preview.alphagov.co.uk"

  # Disable cache in development
  config.cache_store = :null_store

  config.after_initialize do
    Bullet.enable = true
    # Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    # Bullet.airbrake = true

    Rack::MiniProfiler.config.position = 'right'
    Rack::MiniProfiler.config.start_hidden = ENV['HIDE_RACK_MINI_PROFILER'].present? # Use Alt-P shortcut to show
  end

  if ENV['SHOW_PRODUCTION_IMAGES']
    orig_host = config.asset_host
    config.asset_host = Proc.new do |source|
      if source =~ %r{system/uploads}
        "https://assets.digital.cabinet-office.gov.uk"
      else
        orig_host
      end
    end
  end
end
