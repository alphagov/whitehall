source "https://rubygems.org"

gem "rails", "~> 7.2.2"

gem "activemodel-serializers-xml"
gem "addressable"
gem "after_commit_everywhere"
gem "babosa"
gem "bootsnap", require: false
gem "carrierwave"
gem "carrierwave-i18n"
gem "chronic"
gem "content_block_tools"
gem "dalli"
gem "dartsass-rails"
gem "diffy"
gem "flipflop"
gem "fog-aws"
gem "friendly_id"
gem "fuzzy_match"
gem "gds-api-adapters"
gem "gds-sso"
gem "globalize"
gem "govspeak"
gem "govuk_app_config"
gem "govuk_frontend_toolkit"
gem "govuk_publishing_components"
gem "govuk_sidekiq"
gem "inline_svg"
gem "invalid_utf8_rejector"
gem "isbn_validation"
gem "jbuilder"
gem "json_schemer"
gem "kaminari"
gem "link_header"
gem "mail-notify"
gem "marcel"
gem "mime-types"
gem "mini_magick"
gem "mysql2"
gem "nokogiri"
gem "pdf-reader"
gem "plek"
gem "ptools"
gem "rack"
# TODO: remove after next version of Puma is released
# See https://github.com/puma/puma/pull/3532
# `require: false` is needed because you can't actually `require "rackup"`
# due to a different bug: https://github.com/rack/rackup/commit/d03e1789
gem "rackup", "1.0.0", require: false
gem "rails-i18n"
gem "rails_translation_manager"
gem "rake"
gem "record_tag_helper", require: false
gem "redis"
gem "responders"
gem "rinku", require: "rails_rinku"
gem "rubyzip"
gem "sentry-sidekiq"
gem "sidekiq-scheduler"
gem "sprockets-rails"
gem "terser"
gem "transitions", require: ["transitions", "active_record/transitions"]
gem "validates_email_format_of"
gem "view_component"
gem "whenever", require: false

group :development, :test do
  gem "erb_lint", require: false
  gem "pact", require: false
  gem "pact_broker-client"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop-govuk", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  gem "climate_control"
  gem "database_cleaner-active_record"
  gem "equivalent-xml"
  gem "factory_bot"
  gem "fakeredis"
  gem "govuk_schemas"
  gem "i18n-coverage"
  gem "maxitest"
  gem "minitest"
  gem "minitest-fail-fast"
  gem "minitest-stub-const"
  gem "mocha"
  gem "rack-test"
  gem "rails-controller-testing"
  gem "rails-dom-testing"
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
