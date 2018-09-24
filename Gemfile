source 'https://rubygems.org'

gem 'activemodel-serializers-xml'
gem 'addressable', ">= 2.3.7"
gem 'asset_bom_removal-rails', '~> 1.0.0'
gem 'babosa', '1.0.2'
gem 'bootsnap', require: false
gem 'bootstrap-kaminari-views', '0.0.5'
gem 'carrierwave', '~> 1.2.3'
gem 'carrierwave-i18n'
gem 'chronic'
gem 'dalli', '~> 2.7'
gem 'deprecated_columns', '~> 0.1.1'
gem 'equivalent-xml', '~> 0.6.0', require: false
gem 'faraday'
gem 'friendly_id', '~> 5.2.4'
gem 'gds-sso', '~> 13.6'
# Use globalize 5.1, plus an unreleased change to resolve a
# deprecation warning
gem(
  'globalize',
  git: 'https://github.com/globalize/globalize.git',
  ref: 'e946e63983d42c9ff49b39b13ffcc3ad45626dd3'
)
gem 'govuk_ab_testing', '~> 2.4x'
gem 'govuk_admin_template', '~> 6.6'
gem 'govuk_app_config', '~> 1.9'
gem 'govuk_publishing_components', '~> 9.26.0'
gem 'govuk_sidekiq', '~> 3'
gem 'invalid_utf8_rejector', '~> 0.0.4'
gem 'isbn_validation'
gem 'jbuilder'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'kaminari', '~> 1.1.1'
gem 'link_header'
gem 'logstasher', '~> 1.2.1'
gem 'mime-types', '~> 3.2'
gem 'mini_magick', '~> 4.9.2'
gem 'mlanett-redis-lock'
gem 'mysql2', '~> 0.4.10'
gem 'nokogiri', '~> 1.8.3'
gem 'parallel'
gem 'pdf-reader', '~> 2.1'
gem 'plek', '~> 2.1'
gem 'ptools'
gem 'rack', '~> 2.0'
gem 'rack_strip_client_ip', '~> 0.0.2'
gem 'rails', '~> 5.1'
gem 'rails-i18n', '~> 5.1'
gem 'rails_translation_manager', '~> 0.1.0'
gem 'raindrops', '0.19.0'
gem 'rake', '12.3.1'
gem 'record_tag_helper', '~> 1.0'
gem 'redis-namespace'
gem 'responders', '~> 2.4'
gem 'rinku', require: 'rails_rinku'
gem 'ruby-progressbar', require: false
gem 'sass', '~> 3.5'
gem 'sassc-rails', '~> 1.3'
gem 'shared_mustache', '~> 1.0.0'
gem 'sidekiq-scheduler', '~> 3.0'
gem 'slimmer', '~> 13.0'
gem 'sprockets', '~> 3.7'
gem 'sprockets-rails'
gem 'statsd-ruby', '~> 1.4.0', require: 'statsd'
gem 'transitions', require: ['transitions', 'active_record/transitions']
gem 'typhoeus', '~> 1.1'
gem 'uglifier', '~> 4.1'
gem 'unicorn', '5.4.1'
gem 'validates_email_format_of'
gem 'whenever', '~> 0.10.0', require: false

# rubocop:disable Bundler/DuplicatedGem
if ENV['GDS_API_ADAPTERS_DEV']
  gem 'gds-api-adapters', path: '../gds-api-adapters'
else
  gem 'gds-api-adapters'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', path: '../govspeak'
else
  # 5.5.0 only because sanitize 4.6.4 is stricter on govspeak, which makes attachments invalid
  # See https://trello.com/c/90AjvFzy/77-whitehall-isnt-able-to-use-latest-govspeak-version
  gem 'govspeak', '~> 5.5.0'
end

if ENV['FRONTEND_TOOLKIT_DEV']
  gem 'govuk_frontend_toolkit', path: '../govuk_frontend_toolkit_gem'
else
  gem 'govuk_frontend_toolkit', '7.6.0'
end
# rubocop:enable Bundler/DuplicatedGem

group :development, :test do
  gem 'govuk-lint', '~> 3'
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'ruby-prof'
  gem 'teaspoon-qunit'
  gem 'test-queue', '~> 0.2.13'
  # teaspoon has coffee assets that mean we need coffee script in order
  # to be able to run things
  gem 'coffee-rails', '~> 4.2.2'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'graphviz_transitions'
  gem 'stackprof', require: false
  gem 'mechanize'
end

group :test do
  gem 'ci_reporter_minitest'
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'govuk-content-schema-test-helpers'
  gem 'maxitest'
  # minitest 5.11.3 is incompatible with rails 5.0.6
  # this is a temporary downgrade until rails is upgraded
  gem 'minitest', '5.10.3'
  gem 'minitest-fail-fast'
  gem 'minitest-stub-const'
  gem 'mocha'
  gem 'rack-test'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'webmock', require: false
end

group :test_coverage do
  gem 'simplecov'
  gem 'simplecov-rcov'
end

group :cucumber, :test do
  gem 'bourne'
  gem 'cucumber', '~> 2.4.0'
  gem 'cucumber-rails', require: false
  gem 'govuk_test'
  gem 'launchy'
end
