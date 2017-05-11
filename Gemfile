source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '4.2.8'
gem 'rack', '~> 1.6.2'
gem 'statsd-ruby', '~> 1.4.0', require: 'statsd'
gem 'mysql2'
gem 'jquery-ui-rails', '~> 4.1.1'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.9.0'
gem 'validates_email_format_of'
gem 'friendly_id', '~> 5.2.1'
gem 'babosa', '1.0.2'
gem 'nokogiri', '~> 1.6.8.1'
gem 'slimmer', '~> 10.1'
gem 'plek', '~> 2.0'
gem 'isbn_validation'
gem 'gds-sso', '~> 13.2'
gem 'addressable', ">= 2.3.7"
gem 'unicorn', '5.3.0'
gem 'kaminari', '~> 0.17.0'
gem 'govuk_admin_template', '4.2.0'
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'mime-types', '1.25.1'
gem 'whenever', '~> 0.9.7', require: false
gem 'mini_magick', '~> 3.8.1'
gem 'shared_mustache', '~> 0.2.1'
gem 'rails-i18n', '~> 0.7.3'
gem 'link_header'
gem 'logstasher', '0.6.2'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector', '~> 0.0.3'
gem 'govuk_sidekiq', '0.0.4'
gem 'redis-namespace'
gem 'raindrops', '0.15.0'
gem 'airbrake', '4.1.0'
gem 'pdf-reader', '1.3.3'
gem 'typhoeus', '~> 1.1'
gem 'dalli'
gem 'rails_translation_manager', '0.0.1'
gem 'sprockets', '~> 3.0'
gem 'sprockets-rails', '2.3.3'
gem 'rinku', require: 'rails_rinku'
gem 'parallel', '1.4.1'
gem 'responders', '~> 2.0'
gem 'ruby-progressbar', require: false
gem 'equivalent-xml', '0.5.1', require: false
gem 'govuk_ab_testing', '~> 2.2.0'

gem 'deprecated_columns', '0.1.1'

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 41.2.0'
end

if ENV['GLOBALIZE_DEV']
  gem 'globalize', path: '../globalize'
else
  gem 'globalize', '~> 5.0.0'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 3.6.2'
end

if ENV['FRONTEND_TOOLKIT_DEV']
  gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
else
  gem 'govuk_frontend_toolkit', '5.0.3'
end

gem 'sass', '3.4.9'
gem 'sassc-rails'
gem 'uglifier'

group :development, :test do
  gem 'parallel_tests'
  gem 'test-queue', '~> 0.2.13'
  gem 'ruby-prof'
  gem 'pry-byebug'
  gem 'govuk-lint'
  gem 'dotenv-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'newrelic_rpm'
  gem 'quiet_assets'
  gem 'stackprof', require: false
  gem 'graphviz_transitions'
end

group :test do
  gem 'rack-test'
  gem 'factory_girl'
  gem 'mocha', require: false
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter_minitest'
  gem 'database_cleaner'
  gem 'test_track', '~> 0.1.0', git: 'https://github.com/alphagov/test_track'
  gem 'govuk-content-schema-test-helpers'
  gem 'minitest-fail-fast'
  gem 'maxitest'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber, :test do
  gem 'cucumber-rails', require: false
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
end
