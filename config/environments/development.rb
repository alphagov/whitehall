require 'gds_api/gov_uk_delivery'

Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.cache_store = :memory_store

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.slimmer.asset_host = ENV['GOVUK_ASSET_ROOT'] || "https://static.preview.alphagov.co.uk"

  config.after_initialize do
    Bullet.enable = true
    # Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    # Bullet.airbrake = true
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
