source 'http://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'delayed_job_active_record'
gem 'statsd-ruby', '1.0.0', require: "statsd"
gem 'rails', '3.1.12'
gem 'mysql2'
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave'
gem 'govspeak', '~> 1.2.3'
gem 'kramdown', '~> 0.13.8'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.9'
gem 'babosa'
gem 'nokogiri'
gem 'rake', '0.9.2'
gem 'boomerang-rails'
gem 'slimmer', '3.15.0'
gem 'plek', '1.1.0'
gem 'isbn_validation'
gem 'gds-sso', '3.0.4'
gem 'rummageable', '0.6.2'
gem 'addressable'
gem 'exception_notification', require: 'exception_notifier'
gem 'rabl'
gem 'aws-ses', require: 'aws/ses'
gem 'newrelic_rpm', '3.5.3.25'
gem 'lograge'
gem 'unicorn'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '5.5.0'
gem 'whenever', '0.7.3', require: false
gem 'mini_magick'
gem 'shared_mustache', '~> 0.0.2'
gem 'rails-i18n'
gem 'globalize3'
gem 'link_header'

group :assets do
  gem 'govuk_frontend_toolkit', '0.19.2'
  gem 'sass', '3.2.8'
  gem 'sass-rails', '3.1.4'
  gem 'uglifier'
end

group :development, :staging, :test do
  gem 'faker'
  gem 'thin', '1.5.0'
  gem 'quiet_assets'
  gem 'rails-dev-boost', '~> 0.2.1'
  gem 'brakeman'
  gem 'parallel_tests'
  gem 'bullet'
end

group :test do
  # NOTE: keep until https://github.com/brynary/rack-test/pull/69 is merged
  gem 'rack-test', git: 'https://github.com/alphagov/rack-test.git'
  gem 'factory_girl'
  gem 'hash_syntax'
  gem 'mocha', '0.13.2', require: false
  gem 'test_track'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'crack', '~> 0.3.2'
  gem 'minitest', '2.5.1'
  gem 'ci_reporter'
  gem 'database_cleaner', '~> 0.8.0'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber', '~> 1.0.6'
  gem 'cucumber-rails', '~> 1.0.5', require: false
  gem 'launchy', '~> 2.0.5'
  gem 'capybara', '1.1.4'
  gem 'capybara-webkit', '0.12.1'
end

group :router do
  gem 'router-client', '~> 3.0.1', require: 'router'
end
