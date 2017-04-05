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
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Expands the lines which load the assets
  config.assets.debug = ENV['DISABLE_ASSETS_DEBUG'].nil?
  config.assets.cache_store = :null_store
  config.sass.cache = false

  config.slimmer.asset_host = ENV['STATIC_DEV'] || Plek.find('static')
  config.asset_host = Whitehall.admin_root

  # Disable cache in development
  config.cache_store = :null_store

  if ENV['SHOW_PRODUCTION_IMAGES']
    config.asset_host = Proc.new do |source|
      local_file = File.join(Whitehall.clean_uploads_root, source.sub('/government/uploads', ''))
      if !File.exist?(local_file) && source =~ %r{system/uploads}
        "https://assets.publishing.service.gov.uk"
      else
        Whitehall.admin_root
      end
    end
  end
end
