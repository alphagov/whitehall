require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Whitehall
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    require "whitehall"
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Disable rails 7.0+ button_to behaviour
    config.action_view.button_to_generates_button_tag = false

    # Turn off `belongs_to` associations by default. This is turned on by default in Rails 5.0.
    config.active_record.belongs_to_required_by_default = false
    # Support for inversing belongs_to -> has_many Active Record associations.
    config.active_record.has_many_inversing = false

    config.action_controller.per_form_csrf_tokens = false

    # Enable origin-checking CSRF mitigation.
    config.action_controller.forgery_protection_origin_check = false

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W[
      #{config.root}/lib
    ]

    config.action_mailer.notify_settings = {
      api_key: Rails.application.secrets.notify_api_key || "fake-test-api-key",
    }

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "London"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    # We need to set the I18n.available_locales early in the initialization process
    # as it is used to generate the regex for the LocalizedRouting patch. To keep things DRY
    # we use Whitehall.available_locales for the canonical definition of this.
    config.i18n.default_locale = :en
    config.i18n.available_locales = Whitehall.available_locales

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Using a sass css compressor causes a scss file to be processed twice (once
    # to build, once to compress) which breaks the usage of "unquote" to use
    # CSS that has same function names as SCSS such as max
    config.assets.css_compressor = nil

    config.slimmer.wrapper_id = "whitehall-wrapper-slimmer"

    config.action_dispatch.ignore_accept_header = true

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :test_unit, fixture: false
    end

    config.paths["log"] = ENV["LOG_PATH"] if ENV["LOG_PATH"]

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/whitehall"

    unless Rails.application.secrets.jwt_auth_secret
      raise "JWT auth secret is not configured. See config/secrets.yml"
    end
  end
end
