#!/bin/bash -x
export DISPLAY=:99
env
time bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
# bundle exec rake stats
time bundle exec rake db:create db:migrate db:test:prepare --trace && \
RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true time bundle exec rake assets:clean --trace && \
RAILS_ENV=test CUCUMBER_FORMAT=progress time bundle exec rake ci:setup:minitest parallel:prepare parallel:test parallel:features test:javascript test:cleanup --trace && \
RAILS_ENV=production SKIP_OBSERVERS_FOR_ASSET_TASKS=true time bundle exec rake assets:precompile --trace
EXIT_STATUS=$?
echo "EXIT STATUS: $EXIT_STATUS"
exit $EXIT_STATUS
