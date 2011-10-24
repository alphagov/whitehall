#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:create db:migrate db:test:prepare && RAILS_ENV=test bundle exec rake test cucumber --trace
