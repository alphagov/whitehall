source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '4.2.1'
gem 'rack', '~> 1.6.1'  # Bug in Rack 1.6.0 prevents large forms being uploaded in Multipart mode
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.9.0'
gem 'validates_email_format_of'
gem 'friendly_id', '5.2.0.beta.1'
gem 'babosa'
gem 'nokogiri'
gem 'slimmer', '8.2.1'
gem 'plek', '1.10.0'
gem 'isbn_validation'
gem 'gds-sso', '~> 10.0'
gem 'rummageable', '1.2.0'
gem 'addressable'
gem 'unicorn', '4.6.2'
gem 'kaminari', '0.15.1'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '18.7.0'
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
gem 'sprockets', '~> 3.0'
gem 'rinku', require: 'rails_rinku'
gem 'parallel', '1.4.1'
gem 'responders', '~> 2.0'

if ENV['GLOBALIZE_DEV']
  gem 'globalize', path: '../globalize'
else
  gem 'globalize', '~> 5.0.0'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 3.3.0'
end

if ENV['FRONTEND_TOOLKIT_DEV']
  gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
else
  gem 'govuk_frontend_toolkit', '3.1.0'
end

gem 'sass', '3.4.9'
gem 'sass-rails' # required by bootstrap-sass, but not listed as a dependency of it
gem 'sassc-rails', '0.1.0'
gem 'uglifier'

group :development, :test do
  gem 'parallel_tests'
  gem 'test-queue', '0.2.11'
  gem 'ruby-prof'
  gem 'pry-byebug'
  gem 'rubocop', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin', '1.6.3'
  gem 'newrelic_rpm'
  gem 'quiet_assets'
  gem 'spring'
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
  gem 'govuk-content-schema-test-helpers', '1.3.0'
  gem 'rails-perftest'
  gem 'minitest-fail-fast'
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
