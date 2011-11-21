source 'http://rubygems.org'

gem 'rails', '3.1.1'
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
gem 'slimmer', :git => 'git://github.com/alphagov/slimmer.git'
gem 'plek', git: 'git://github.com/alphagov/plek.git'

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
  gem 'cucumber-rails', '~> 1.0.5'
  gem 'database_cleaner', '~> 0.5.2'
  gem 'factory_girl', '~> 2.2.0'
  gem 'launchy', '~> 2.0.5'
  gem 'hash_syntax'
  gem 'mocha', :require => false
  gem 'test_track'
  gem 'timecop'
  gem 'versionomy'
end