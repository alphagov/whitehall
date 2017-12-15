source 'https://rubygems.org'

gem 'rake', '12.0.0'
gem 'rails', '5.0.6'
gem 'rack', '~> 2.0'
gem 'statsd-ruby', '~> 1.4.0', require: 'statsd'
gem 'mysql2'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'carrierwave', '~> 1.1.0'
gem 'carrierwave-i18n'
gem 'validates_email_format_of'
gem 'friendly_id', '~> 5.2.1'
gem 'babosa', '1.0.2'
gem 'nokogiri', '~> 1.8.0'
gem 'slimmer', '~> 11.0'
gem 'plek', '~> 2.0'
gem 'isbn_validation'
gem 'gds-sso', '~> 13.2'
gem 'addressable', ">= 2.3.7"
gem 'unicorn', '5.3.1'
gem 'kaminari', '~> 1.0.1'
gem 'govuk_admin_template', '~> 6.2'
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'mime-types', '~> 3.1'
gem 'whenever', '~> 0.9.7', require: false
gem 'mini_magick', '~> 3.8.1'
gem 'shared_mustache', '~> 1.0.0'
gem 'rails-i18n', '~> 5.0'
gem 'link_header'
gem 'logstasher', '~> 1.2.1'
gem 'chronic'
gem 'jbuilder'
gem 'rack_strip_client_ip', '~> 0.0.2'
gem 'invalid_utf8_rejector', '~> 0.0.4'
gem 'govuk_sidekiq', '2.0.0'
gem 'sidekiq-scheduler', '~> 2.1'
gem 'redis-namespace'
gem 'raindrops', '0.18.0'
gem 'govuk_app_config', '~> 0.2.0'
gem 'pdf-reader', '~> 2.0'
gem 'typhoeus', '~> 1.1'
gem 'dalli', '~> 2.7'
gem 'rails_translation_manager', '~> 0.0.2'
gem 'sprockets', '~> 3.7'
gem 'sprockets-rails'
gem 'rinku', require: 'rails_rinku'
gem 'parallel'
gem 'responders', '~> 2.4'
gem 'ruby-progressbar', require: false
gem 'equivalent-xml', '~> 0.6.0', require: false
gem 'mlanett-redis-lock'
gem 'faraday'
gem 'globalize', '5.1.0.beta2'
gem 'activemodel-serializers-xml'
gem 'deprecated_columns', '~> 0.1.1'
gem 'record_tag_helper', '~> 1.0'
gem 'govuk_ab_testing', '~> 2.4x'

if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  gem 'govspeak', '~> 5.1.0'
end

if ENV['FRONTEND_TOOLKIT_DEV']
  gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
else
  gem 'govuk_frontend_toolkit', '7.0.1'
end

gem 'asset_bom_removal-rails', '~> 1.0.0'
gem 'sass', '~> 3.5'
gem 'sassc-rails', '~> 1.3'
gem 'uglifier', '~> 3.2'

group :development, :test do
  gem 'parallel_tests'
  gem 'test-queue', '~> 0.2.13'
  gem 'ruby-prof'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'govuk-lint', '~> 3.3.1'
  gem 'dotenv-rails'
  gem 'teaspoon-qunit'
  # teaspoon has coffee assets that mean we need coffee script in order
  # to be able to run things
  gem 'coffee-rails', '~> 4.1.0'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'newrelic_rpm'
  gem 'stackprof', require: false
  gem 'graphviz_transitions'
end

group :test do
  gem 'rack-test'
  gem 'factory_bot'
  gem 'mocha', require: false
  gem 'timecop'
  gem 'webmock', require: false
  gem 'ci_reporter_minitest'
  gem 'database_cleaner'
  gem 'govuk-content-schema-test-helpers'
  gem 'minitest-fail-fast'
  gem 'maxitest'
  gem 'rails-controller-testing'
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber, :test do
  gem 'cucumber-rails', require: false
  gem 'cucumber', '~> 2.4.0'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
end
