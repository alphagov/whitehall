source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '4.1.9'
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.9.0'
gem 'validates_email_format_of'
gem 'friendly_id', '5.0.4'
gem 'babosa'
gem 'nokogiri'
gem 'slimmer', '8.1.0'
gem 'plek', '1.10.0'
gem 'isbn_validation'
gem 'gds-sso', '~> 10.0'
gem 'rummageable', '1.2.0'
gem 'addressable'
gem 'unicorn', '4.6.2'
gem 'kaminari', '0.15.1'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '18.1.0'
gem 'whenever', '0.9.4', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.2.0'
gem 'rails-i18n'
gem 'link_header'
gem 'logstasher', '0.6.2'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector', '~> 0.0.1'
gem 'sidekiq', '~> 3.3.0'
gem 'sidekiq-logging-json', '0.0.14'
gem 'raindrops', '0.11.0'
gem 'airbrake', '4.1.0'
gem 'pdf-reader', '1.3.3'
gem 'typhoeus', '0.6.9'
gem 'bootstrap-sass', '2.3.2.2'
gem 'dalli'
gem 'rails_translation_manager', '0.0.1'
gem 'rails-observers'
gem 'sprockets', '3.0.0.beta.8'

if ENV['GLOBALIZE_DEV']
  gem 'globalize', path: '../globalize'
else
  # Note: a fix for the issue that necessitates this fork has been merged into
  # globalize master, but that version is only compatible with ActiveRecord 4.2
  # and above. Once Whitehall is running on Rails 4.2, we can switch to using
  # the main fork of globalize.
  gem 'globalize', github: 'tekin/globalize', ref: 'transalted-model-touch-issue'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 3.2.0'
end

if ENV['FRONTEND_TOOLKIT_DEV']
  gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
else
  gem 'govuk_frontend_toolkit', '3.1.0'
end

gem 'sass', '3.4.9'
gem 'sass-rails'
gem 'uglifier'

group :development, :test do
  gem 'parallel_tests'
  gem 'test-queue', '0.2.11'
  gem 'ruby-prof'
  gem 'pry-byebug'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin', '1.6.3'
  gem 'newrelic_rpm'
  gem 'quiet_assets'
  gem 'rubocop'
end

group :test do
  gem 'rack-test', '~> 0.6.3'
  gem 'factory_girl'
  gem 'mocha', '1.1.0', require: false
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter'
  gem 'database_cleaner', '1.4.0'
  gem 'equivalent-xml', '0.5.1', require: false
  gem 'test_track', '~> 0.1.0', github: 'alphagov/test_track'
  gem 'govuk-content-schema-test-helpers', '1.0.1'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber-rails', '~> 1.4', require: false
  gem 'launchy', '~> 2.4.3'
  gem 'capybara', '~> 2.4.4'
  gem 'poltergeist', '~> 1.5.1'
end
