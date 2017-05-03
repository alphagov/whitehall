require File.expand_path('../boot', __FILE__)

require "rails"
require 'active_record'

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Whitehall
  class Application < Rails::Application
    require 'whitehall'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/lib
    )

    # Opt in to new transaction callback error handling behaviour to get rid of
    # deprecation warnings.
    #
    # See http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#error-handling-in-transaction-callbacks
    config.active_record.raise_in_transactional_callbacks = true

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # We need to set the I18n.available_locales early in the initialization process
    # as it is used to generate the regex for the LocalizedRouting patch. To keep things DRY
    # we use Whitehall.available_locales for the canonical definition of this.
    config.i18n.default_locale = :en
    config.i18n.available_locales = Whitehall.available_locales

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable the asset pipeline
    config.assets.initialize_on_precompile = true

    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.prefix = Whitehall.router_prefix + config.assets.prefix
    config.slimmer.wrapper_id = "whitehall-wrapper"

    config.action_dispatch.ignore_accept_header = true

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :test_unit, fixture: false
    end
  end
end
