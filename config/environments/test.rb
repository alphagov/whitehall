Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  if ENV["DISABLE_LOGGING_IN_TEST"]
    File.open(Rails.root.join("log", "test.log"), "a") do |file|
      file.puts "\n*NOTE* Disabling logging in an attempt to speed up the tests.\n\n"
    end
    config.logger = Logger.new(nil)
  end

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Allow pass debug_assets=true as a query parameter to load pages with unpackaged assets
  config.assets.allow_debugging = true

  config.slimmer.asset_host = "http://tests-should-not-depend-on-external-host.com"

  # This is required for Plek 1.x, but we don't want to have to set it
  # when running the tests.
  if ENV['GOVUK_APP_DOMAIN'].blank?
    ENV['GOVUK_APP_DOMAIN'] = 'test.gov.uk'
  end

  if ENV['GOVUK_ASSET_ROOT'].blank?
    ENV['GOVUK_ASSET_ROOT'] = 'http://static.test.gov.uk'
  end
end

require Rails.root.join("test/support/skip_slimmer")
TestTrack.application_manifest = "all"

Whitehall.skip_safe_html_validation = true
