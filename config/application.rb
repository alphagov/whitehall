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
    config.load_defaults 7.1

    # config.active_support.cache_format_version = 7.1

    # Disable rails 7.0+ button_to behaviour
    config.action_view.button_to_generates_button_tag = false

    # Turn off `belongs_to` associations by default. This is turned on by default in Rails 5.0.
    config.active_record.belongs_to_required_by_default = false
    # Support for inversing belongs_to -> has_many Active Record associations.
    config.active_record.has_many_inversing = false

    # Run after_commit callbacks on the first of multiple Active Record
    # instances to save changes to the same database row within a transaction.
    # If false, run these callbacks on the instance most likely to have internal
    # state which matches what was committed to the database, typically the last
    # instance to save. This is the default in Rails 7.1, but breaks some Whitehall
    # flows.
    config.active_record.run_commit_callbacks_on_first_saved_instances_in_transaction = true

    # Disable before_committed! callbacks on all enrolled records in a transaction.
    # The new behavior is to only run the callbacks on the first copy of a record
    # if there are multiple copies of the same record enrolled in the transaction.
    # However, that causes problems for some of Whitehall's callback logic
    config.active_record.before_committed_on_all_records = false

    # Run `after_commit` and `after_*_commit` callbacks in the inverse order they are defined in a model.
    # In versions >= 7.1 of Rails, they run in the order they are defined by default.
    config.active_record.run_after_transaction_callbacks_in_order_defined = false

    config.action_controller.per_form_csrf_tokens = false

    # Enable origin-checking CSRF mitigation.
    config.action_controller.forgery_protection_origin_check = false

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W[
      #{config.root}/lib
    ]

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

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

    config.action_dispatch.ignore_accept_header = true

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation can not be found)
    config.i18n.fallbacks = true

    # Allows us to add custom full messages to locale files which will override
    # overrides the default behaviour of full_message and returns the translation
    # when a translation is present
    config.active_model.i18n_customize_full_message = true

    config.generators do |generate|
      generate.helper false
      generate.assets false
      generate.test_framework :test_unit, fixture: false
    end

    config.paths["log"] = ENV["LOG_PATH"] if ENV["LOG_PATH"]

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/whitehall"

    # Serve error pages from app instead of static pages
    config.exceptions_app = routes

    unless Rails.application.secrets.jwt_auth_secret
      raise "JWT auth secret is not configured. See config/secrets.yml"
    end

    # Before filter for Flipflop dashboard. Replace with a lambda or method name
    # defined in ApplicationController to implement access control.
    config.flipflop.dashboard_access_filter = -> { head :forbidden unless Rails.env.development? }

    # By default, when set to `nil`, strategy loading errors are suppressed in test
    # mode. Set to `true` to always raise errors, or `false` to always warn.
    config.flipflop.raise_strategy_errors = nil
  end
end
