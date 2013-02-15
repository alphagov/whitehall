require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'tire/rails/logger'


if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(assets: %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Whitehall
  class Application < Rails::Application
    require 'whitehall'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/presenters #{config.root}/app/validators)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    unless ENV["SKIP_OBSERVERS_FOR_ASSET_TASKS"].present?
      config.active_record.observers = :ministerial_role_search_index_observer, :supporting_page_search_index_observer
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'London'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]

    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :ar, :az, :be, :bg, :bn, :cs, :de, :dr, :el, :es, :fa, :fr, :he, :hi, :hu, :hy, :id, :it, :ja, :ka, :ko, :lt, :lv, :ms, :pl, :ps, :pt, :ro, :ru, :si, :sk, :so, :sq, :sr, :sw, :ta, :th, :tk, :tr, :uk, :ur, :uz, :vi, :zh]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.prefix = Whitehall.router_prefix + config.assets.prefix
    config.slimmer.wrapper_id = "whitehall-wrapper"

    config.action_dispatch.ignore_accept_header = true
  end
end
