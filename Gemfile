source 'https://rubygems.org'

gem 'rake', '10.1.0'
gem 'rails', '3.2.18'
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.9.0'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.9'
gem 'babosa'
gem 'nokogiri'
gem 'slimmer', '4.3.1'
gem 'plek', '1.9.0'
gem 'isbn_validation'
gem 'gds-sso', '9.3.0'
gem 'rummageable', '1.0.0'
gem 'addressable'
gem 'unicorn', '4.6.2'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '14.5.0'
gem 'whenever', '0.9.0', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.0.2'
gem 'rails-i18n'
gem 'globalize3', github: 'globalize/globalize', ref: 'ab69160ad'
gem 'link_header'
gem 'logstasher', '0.4.8'
gem 'slop', '3.4.5'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector', '~> 0.0.1'
gem 'sidekiq', '~> 3.2.1'
gem 'raindrops', '0.11.0'
gem 'airbrake', '3.1.15'
gem 'pdf-reader', '1.3.3'
gem 'typhoeus', '0.6.8'
gem 'bootstrap-sass', '2.3.2.2'
gem 'dalli'

# Gems to smooth transition to Rails 4
gem 'strong_parameters'

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 3.2.0'
end

group :assets do
  if ENV['FRONTEND_TOOLKIT_DEV']
    gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
  else
    gem 'govuk_frontend_toolkit', '2.0.1'
  end
  gem 'sass', '3.2.8'
  gem 'sass-rails'
  gem 'uglifier'
end

group :development, :test do
  gem 'debugger'
  gem 'parallel_tests'
  gem 'test-queue'
  gem 'ruby-prof'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin', '1.5.1'
  gem 'newrelic_rpm'
  gem 'quiet_assets'
  gem 'rubocop'
end

group :test do
  gem 'rack-test', github: 'brynary/rack-test', ref: '8cdb86e1'
  gem 'factory_girl'
  gem 'mocha', '0.14.0', require: false
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter'
  gem 'database_cleaner', '1.0.1'
  gem 'equivalent-xml', '0.3.0', require: false
  gem 'test_track', '~> 0.1.0', github: 'alphagov/test_track'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber-rails', '~> 1.4', require: false
  gem 'launchy', '~> 2.3.0'
  gem 'capybara', '~> 2.1.0'
  gem 'poltergeist', '~> 1.5.1'
end
