source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

gem 'rails', '3.1.3'
gem 'rack', '1.3.5'
gem 'mysql2'
gem 'jquery-rails'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave'
gem 'govspeak', :git => 'git://github.com/alphagov/govspeak.git'
gem 'validates_email_format_of'
gem 'friendly_id', '4.0.0.beta14'
gem 'nokogiri'
gem 'rake', '0.9.2.2'
gem 'boomerang-rails'
gem 'slimmer', '1.1.19'
gem 'plek'
gem 'fog'
gem 'pdf-reader'
gem 'isbn_validation'
gem 'gds-sso', git: 'git://github.com/alphagov/gds-sso.git'
gem 'rummageable', git: 'git://github.com/alphagov/rummageable.git'

group :assets do
  gem 'sass-rails', '~> 3.1.0'
  gem 'coffee-rails', '~> 3.1.0'
  gem 'uglifier'
  gem 'therubyracer'
end

group :development, :staging, :test do
  gem 'faker'
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
  gem 'versionomy'
  gem 'webmock'
end

group :router do
  gem 'router-client', git: "git://github.com/alphagov/router-client.git", require: "router"
end