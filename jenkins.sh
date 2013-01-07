#!/bin/bash -xe
export DISPLAY=:99
env

time bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

govuk_setenv whitehall time bundle exec rake db:create db:migrate db:test:prepare --trace
govuk_setenv whitehall env RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true time bundle exec rake assets:clean --trace
govuk_setenv whitehall env RAILS_ENV=test CUCUMBER_FORMAT=progress time bundle exec rake ci:setup:minitest default test:cleanup --trace
govuk_setenv whitehall env RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true time bundle exec rake assets:precompile --trace

EXIT_STATUS=$?
echo "EXIT STATUS: $EXIT_STATUS"
exit $EXIT_STATUS
