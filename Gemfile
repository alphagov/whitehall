source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '4.2.7.1'
gem 'rack', '~> 1.6.2'
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem 'jquery-ui-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.9.0'
gem 'validates_email_format_of'
gem 'friendly_id', '5.0.4'
gem 'babosa', '1.0.2'
gem 'nokogiri', '~> 1.6.7.2'
gem 'slimmer', '9.0.1'
gem 'plek', '~> 1.12'
gem 'isbn_validation'
gem 'gds-sso', '~> 11.0'
gem 'rummageable', '1.2.0'
gem 'addressable', ">= 2.3.7"
gem 'unicorn', '5.0.0'
gem 'kaminari', '0.15.1'
gem 'govuk_admin_template', '4.2.0'
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'mime-types', '1.25.1'
gem 'whenever', '0.9.4', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.2.1'
gem 'rails-i18n'
gem 'link_header'
gem 'logstasher', '0.6.2'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector', '~> 0.0.1'
gem 'govuk_sidekiq', '0.0.4'
gem 'redis-namespace'
gem 'raindrops', '0.15.0'
gem 'airbrake', '4.1.0'
gem 'pdf-reader', '1.3.3'
gem 'typhoeus', '0.6.9'
gem 'dalli'
gem 'rails_translation_manager', '0.0.1'
gem 'rails-observers'
gem 'sprockets', '~> 3.0'
gem 'sprockets-rails', '2.3.3'
gem 'rinku', require: 'rails_rinku'
gem 'parallel', '1.4.1'
gem 'responders', '~> 2.0'
gem 'ruby-progressbar', require: false

gem 'deprecated_columns', '0.1.0'

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters', '~> 32.0.0'
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
  gem 'govuk_frontend_toolkit', '4.16.0'
end

gem 'sass', '3.4.9'
gem 'sassc-rails'
gem 'uglifier'

group :development, :test do
  gem 'parallel_tests'
  gem 'test-queue', '0.2.11'
  gem 'ruby-prof'
  gem 'pry-byebug'
  gem 'govuk-lint', '~> 0.5.1'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin', '1.6.3'
  gem 'newrelic_rpm'
  gem 'quiet_assets'
  gem 'stackprof', require: false
  gem 'graphviz_transitions'
end

group :test do
  gem 'rack-test', '~> 0.6.3'
  gem 'factory_girl'
  gem 'mocha', '1.1.0', require: false
  gem 'timecop'
  gem 'webmock', '~> 2.1', require: false
  gem 'ci_reporter'
  gem 'database_cleaner', '1.4.0'
  gem 'equivalent-xml', '0.5.1', require: false
  gem 'test_track', '~> 0.1.0', github: 'alphagov/test_track', branch: 'master'
  gem 'govuk-content-schema-test-helpers', '1.4.0'
  gem 'minitest-fail-fast'
  gem 'maxitest'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber-rails', '~> 1.4.2', require: false
  gem 'launchy', '~> 2.4.3'
  gem 'capybara', '~> 2.4.4'
  gem 'poltergeist', '~> 1.5.1'
end
