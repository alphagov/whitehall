#!/bin/bash -x
export DISPLAY=:99
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:create db:migrate db:test:prepare && \
RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true bundle exec rake assets:clean --trace && \
RAILS_ENV=test CUCUMBER_FORMAT=progress bundle exec rake default test:cleanup --trace && \
RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true bundle exec rake assets:precompile --trace
