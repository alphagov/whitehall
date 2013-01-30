source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'delayed_job_active_record'
gem 'statsd-ruby', '1.0.0', require: "statsd"
gem 'rails', '3.1.10'
gem 'mysql2'
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave'
gem 'govspeak', '~> 1.2.3'
gem 'kramdown', '~> 0.13.8'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.0.beta14'
gem 'nokogiri'
gem 'rake', '0.9.2'
gem 'boomerang-rails'
gem 'slimmer', '3.10.1'
gem 'plek', '1.1.0'
gem 'fog'
gem 'pdf-reader'
gem 'isbn_validation'
gem 'gds-sso', '3.0.0'
gem 'rummageable', '0.6.2'
gem 'tire', git: "https://github.com/alphagov/tire.git"
gem 'addressable'
gem 'exception_notification', require: 'exception_notifier'
gem 'rabl'
gem "paper_trail"
gem 'aws-ses', require: 'aws/ses'
gem 'draper'
gem 'newrelic_rpm', '3.5.3.25'
gem 'lograge'
gem 'unicorn'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'gds-api-adapters', '4.3.0'
gem 'whenever', '0.7.3', require: false
gem 'mini_magick'

group :assets do
  gem 'govuk_frontend_toolkit', '0.12.1'
  gem 'sass', '3.2.5'
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
end

group :test do
  # NOTE: keep until https://github.com/brynary/rack-test/pull/69 is merged
  gem 'rack-test', git: 'https://github.com/alphagov/rack-test.git'
  gem 'factory_girl'
  gem 'hash_syntax'
  gem 'mocha', '0.10.0', require: false
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
  gem 'capybara-webkit'
end

group :router do
  gem 'router-client', '~> 3.0.1', require: 'router'
end
