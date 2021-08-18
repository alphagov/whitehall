source "https://rubygems.org"

gem "rails", "6.1.4"

gem "activemodel-serializers-xml"
gem "addressable"
gem "babosa"
gem "bootsnap", require: false
gem "bootstrap-kaminari-views"
gem "carrierwave"
gem "carrierwave-i18n"
gem "chronic"
gem "dalli"
gem "faraday"
gem "fog-aws"
gem "friendly_id"
gem "fuzzy_match"
gem "gds-api-adapters"
gem "gds-sso"
gem "globalize"
gem "govspeak"
gem "govuk_ab_testing"
gem "govuk_admin_template"
gem "govuk_app_config", "4.0.0"
gem "govuk_frontend_toolkit"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "invalid_utf8_rejector"
gem "isbn_validation"
gem "jbuilder"
gem "jquery-ui-rails"
gem "kaminari"
gem "link_header"
gem "mail-notify"
gem "mime-types"
gem "mini_magick"
gem "mlanett-redis-lock"
gem "mysql2"
gem "nokogiri"
gem "pdf-reader"
gem "plek"
gem "ptools"
gem "rack"
gem "rack_strip_client_ip"
gem "rails-i18n"
gem "rails_translation_manager"
gem "rake"
gem "record_tag_helper", require: false
gem "responders"
gem "rinku", require: "rails_rinku"
gem "ruby-progressbar", require: false
gem "rubyzip"
gem "sassc-rails"
gem "shared_mustache"
gem "sidekiq-scheduler"
gem "slimmer"
gem "sprockets-rails"
gem "transitions", require: ["transitions", "active_record/transitions"]
gem "uglifier"
gem "validates_email_format_of"
gem "whenever", require: false

group :development, :test do
  gem "pact", require: false
  gem "pact_broker-client"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop-govuk", require: false
  gem "teaspoon-qunit"
  gem "test-queue"
  # teaspoon has coffee assets that mean we need coffee script in order
  # to be able to run things
  gem "coffee-rails"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "graphviz_transitions"
  gem "i18n-tasks"
  gem "mechanize"
end

group :test do
  gem "ci_reporter_minitest"
  gem "database_cleaner"
  gem "equivalent-xml"
  gem "factory_bot"
  gem "govuk-content-schema-test-helpers"
  gem "i18n-coverage"
  gem "maxitest"
  gem "minitest"
  gem "minitest-fail-fast"
  gem "minitest-stub-const"
  gem "mocha"
  gem "rack-test"
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock", require: false
end

group :cucumber, :test do
  gem "cucumber"
  gem "cucumber-rails", require: false
  gem "govuk_test"
  gem "launchy"
end
