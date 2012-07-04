source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '3.1.3'
gem 'rack', '1.3.5'
gem 'mysql2'
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave'
gem 'govspeak', '~> 0.8.15'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.0.beta14'
gem 'nokogiri'
gem 'rake', '0.9.2'
gem 'boomerang-rails'
gem 'slimmer', '1.1.41'
gem 'plek'
gem 'fog'
gem 'pdf-reader'
gem 'isbn_validation'
gem 'gds-sso', '0.7.7'
gem 'rummageable', git: 'git://github.com/alphagov/rummageable.git'
gem 'addressable'
gem 'exception_notification', require: 'exception_notifier'
gem 'rabl'
gem "paper_trail"
gem 'aws-ses', require: 'aws/ses'
gem 'draper'

group :assets do
  gem 'sass-rails', '~> 3.1.0'
  gem 'uglifier'
end

group :development, :staging, :test do
  gem 'faker'
  gem 'thin'
  gem 'quiet_assets'
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git', :require => 'rails_development_boost'
end

group :test do
  gem 'cucumber', '~> 1.0.6'
  gem 'cucumber-rails', '~> 1.0.5', require: false
  gem 'database_cleaner', '~> 0.5.2'
  gem 'factory_girl', '~> 2.2.0'
  gem 'launchy', '~> 2.0.5'
  gem 'hash_syntax'
  gem 'mocha', :require => false
  gem 'test_track'
  gem 'timecop'
  gem 'webmock', require: false
  gem 'capybara-webkit'
end

group :router do
  gem 'router-client', '~> 3.0.1', :require => 'router'
end
