source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '3.1.7'
gem 'mysql2'
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave'
if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 1.0.1'
end
gem 'kramdown', git: 'https://github.com/alphagov/kramdown.git', branch: "add-gemspec"
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.0.beta14'
gem 'nokogiri'
gem 'rake', '0.9.2'
gem 'boomerang-rails'
gem 'slimmer', '3.3.2'
gem 'plek'
gem 'fog'
gem 'pdf-reader'
gem 'isbn_validation'
gem 'gds-sso', '~> 1.2.2'
gem 'gds-api-adapters'
gem 'rummageable', git: 'https://github.com/alphagov/rummageable.git'
gem 'addressable'
gem 'exception_notification', require: 'exception_notifier'
gem 'rabl'
gem "paper_trail"
gem 'aws-ses', require: 'aws/ses'
gem 'draper'
gem 'newrelic_rpm'
gem 'lograge'
gem 'unicorn'
gem 'kaminari'
gem 'bootstrap-kaminari-views'

group :assets do
  gem 'sass', '3.2.1'
  gem 'sass-rails', '3.1.4'
  gem 'uglifier'
end

group :development, :staging, :test do
  gem 'faker'
  gem 'thin'
  gem 'quiet_assets'
  gem 'rails-dev-boost', git: 'https://github.com/thedarkone/rails-dev-boost.git', require: 'rails_development_boost'
  gem 'brakeman'
end

group :test do
  gem 'factory_girl', '~> 2.6.0'
  gem 'hash_syntax'
  gem 'mocha', '0.10.0', require: false
  gem 'test_track'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'minitest', '2.5.1'
  gem 'ci_reporter'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber do
  gem 'cucumber', '~> 1.0.6'
  gem 'cucumber-rails', '~> 1.0.5', require: false
  gem 'database_cleaner', '~> 0.5.2'
  gem 'launchy', '~> 2.0.5'
  gem 'capybara-webkit'
end

group :router do
  gem 'router-client', '~> 3.0.1', require: 'router'
end
