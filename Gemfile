source 'https://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'rake', '0.9.2'
gem 'rails', '3.2.14'
gem 'statsd-ruby', '~> 1.2.1', require: 'statsd'
gem 'mysql2'
gem 'delayed_job_active_record'
gem 'jquery-rails', '1.0.19'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '0.8.0'
gem 'govspeak', '~> 1.2.3'
gem 'kramdown', '~> 0.13.8'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.9'
gem 'babosa'
gem 'nokogiri'
gem 'slimmer', '3.22.0'
gem 'plek', '1.5.0'
gem 'isbn_validation'
gem 'gds-sso', '3.0.4'
gem 'rummageable', '1.0.0'
gem 'addressable'
gem 'exception_notification', require: 'exception_notifier'
gem 'aws-ses', require: 'aws/ses'
gem 'lograge'
gem 'unicorn', '4.6.2'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '7.18.0'
gem 'whenever', '0.7.3', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.0.2'
gem 'rails-i18n'
gem 'globalize3', github: 'globalize/globalize', ref: 'ab69160ad'
gem 'link_header'
gem 'logstasher', '0.2.5'
gem 'slop', '3.4.5'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '0.0.1'
gem 'invalid_utf8_rejector', '~> 0.0.1'
gem 'sidekiq', '2.14.1'
gem 'raindrops', '0.11.0'
gem 'charlock_holmes'

group :assets do
  gem 'govuk_frontend_toolkit', '0.38.0'
  gem 'sass', '3.2.8'
  gem 'sass-rails'
  gem 'uglifier'
end

group :development, :test do
  gem 'debugger'
  gem 'parallel_tests'
  gem 'test-queue'
end

group :development do
  gem 'thin', '1.5.1'
  gem 'bullet'
  gem 'newrelic_rpm'
  gem 'rack-mini-profiler'
  gem 'rails-dev-boost'
  gem 'quiet_assets'
end

group :test do
  gem 'rack-test', github: 'brynary/rack-test'
  gem 'factory_girl'
  gem 'hash_syntax'
  gem 'mocha', '0.14.0', require: false
  gem 'test_track', github: 'episko/test_track'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter'
  gem 'database_cleaner', '1.0.1'
  gem 'equivalent-xml', '0.3.0', require: false
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber', '~> 1.3.2'
  gem 'cucumber-rails', '~> 1.3.1', require: false
  gem 'launchy', '~> 2.3.0'
  gem 'capybara', '~> 2.1.0'
  gem 'poltergeist', '~> 1.3.0'
end

group :router do
  gem 'router-client', '~> 3.0.1', require: 'router'
end
