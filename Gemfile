source "https://rubygems.org"

gem "activemodel-serializers-xml"
gem "addressable", ">= 2.3.7"
gem "babosa", "1.0.3"
gem "bootsnap", require: false
gem "bootstrap-kaminari-views", "0.0.5"
gem "carrierwave", "~> 2.1.0"
gem "carrierwave-i18n"
gem "chronic"
gem "dalli", "~> 2.7"
gem "faraday"
gem "friendly_id", "~> 5.3.0"
gem "fuzzy_match", "~> 2.1"
gem "gds-api-adapters"
gem "gds-sso", "~> 14.2"
gem "globalize", "~> 5"
gem "govspeak", "~> 6.5"
gem "govuk_ab_testing", "~> 2.4x"
gem "govuk_admin_template", "~> 6.7"
gem "govuk_app_config", "~> 2.0"
gem "govuk_frontend_toolkit", "8.2.0"
gem "govuk_publishing_components", "~> 21.27.1"
gem "govuk_sidekiq", "~> 3"
gem "invalid_utf8_rejector", "~> 0.0.4"
gem "isbn_validation"
gem "jbuilder"
gem "jquery-ui-rails", "~> 4.2.1"
gem "kaminari", "~> 1.1.1"
gem "link_header"
gem "mime-types", "~> 3.3"
gem "mini_magick", "~> 4.10.1"
gem "mlanett-redis-lock"
gem "mysql2", "~> 0.4.10"
gem "nokogiri", "~> 1.10.5"
gem "parallel"
gem "pdf-reader", "~> 2.2"
gem "plek", "~> 3.0"
gem "ptools"
gem "rack", "~> 2.0"
gem "rack_strip_client_ip", "~> 0.0.2"
gem "rails", "~> 5.1"
gem "rails-i18n", "~> 5.1"
gem "rails_translation_manager", "~> 0.1.0"
gem "rake", "13.0.1"
gem "record_tag_helper", "~> 1.0"
gem "responders", "~> 3.0"
gem "rinku", require: "rails_rinku"
gem "ruby-progressbar", require: false
gem "rubyzip", "~> 2.1"
gem "sass", "~> 3.7"
gem "sassc-rails", "~> 2.1"
gem "shared_mustache", "~> 1.0.0"
gem "sidekiq-scheduler", "~> 3.0"
gem "slimmer", "~> 13.2"
gem "sprockets-rails"
gem "transitions", require: ["transitions", "active_record/transitions"]
gem "uglifier", "~> 4.2"
gem "validates_email_format_of"
gem "whenever", "~> 1.0.0", require: false

group :development, :test do
  gem "parallel_tests"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop-govuk", "~> 3"
  gem "teaspoon-qunit"
  gem "test-queue", "~> 0.2.13"
  # teaspoon has coffee assets that mean we need coffee script in order
  # to be able to run things
  gem "coffee-rails", "~> 4.2.2"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "graphviz_transitions"
  gem "mechanize"
end

group :test do
  gem "ci_reporter_minitest"
  gem "database_cleaner"
  gem "equivalent-xml", "~> 0.6.0"
  gem "factory_bot"
  gem "govuk-content-schema-test-helpers"
  gem "maxitest"
  gem "minitest"
  gem "minitest-fail-fast"
  gem "minitest-stub-const"
  gem "mocha"
  gem "rack-test"
  gem "rails-controller-testing"
  gem "timecop"
  gem "webmock", require: false
end

group :cucumber, :test do
  gem "cucumber", "~> 3"
  gem "cucumber-rails", require: false
  gem "govuk_test"
  gem "launchy"
end
