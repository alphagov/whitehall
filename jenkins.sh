#!/bin/bash -x
export DISPLAY=:99
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:create db:migrate db:test:prepare && \
RAILS_ENV=test CUCUMBER_FORMAT=progress bundle exec rake default test:cleanup --trace && \
RAILS_ENV=production PRECOMPILING_ASSETS=true bundle exec rake assets:precompile --trace
