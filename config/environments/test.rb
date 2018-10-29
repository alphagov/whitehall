Whitehall::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Disable cache in test
  config.cache_store = :null_store

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.log_level = (ENV['LOG_LEVEL'].presence || :debug).to_sym

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Allow pass debug_assets=true as a query parameter to load pages with unpackaged assets
  config.assets.allow_debugging = true

  # Don't use digests in assets during tests
  config.assets.digest = false

  config.slimmer.asset_host = "http://tests-should-not-depend-on-external-host.com"

  # These environment variables are required for Plek. Conditionally setting
  # them here means we don't have to explicitly set them just to run tests.
  ENV['GOVUK_APP_DOMAIN'] ||= 'test.gov.uk'
  ENV['GOVUK_APP_DOMAIN_EXTERNAL'] ||= 'test.gov.uk'
  ENV['GOVUK_ASSET_ROOT'] ||= 'https://static.test.gov.uk'
end

require Rails.root.join("test/support/skip_slimmer")

Whitehall.skip_safe_html_validation = true
