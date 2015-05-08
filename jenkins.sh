#!/bin/bash -xe
export DISPLAY=:99
export GOVUK_APP_DOMAIN=test.alphagov.co.uk
export GOVUK_ASSET_ROOT=http://static.test.alphagov.co.uk
env

function github_status {
  STATUS="$1"
  MESSAGE="$2"
  if [ "$GIT_BRANCH" != "origin/master" ]; then
    gh-status alphagov/whitehall "$GIT_COMMIT" "$STATUS" -d "Build #${BUILD_NUMBER} ${MESSAGE}" -u "$BUILD_URL" >/dev/null
  fi
}

function error_handler {
  trap - ERR # disable error trap to avoid recursion
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  github_status failure "failed on Jenkins"
  exit "${code}"
}

trap "error_handler ${LINENO}" ERR
github_status pending "is running on Jenkins"

# Ensure there are no artefacts left over from previous builds
git clean -fdx

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

# Generate directories for upload tests
mkdir -p ./incoming-uploads
mkdir -p ./clean-uploads
mkdir -p ./infected-uploads
mkdir -p ./attachment-cache

# Clone govuk-content-schemas depedency for contract tests
rm -rf tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas

time bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load
RAILS_ENV=test GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas time bundle exec rake ci:setup:minitest test:in_parallel --trace
RAILS_ENV=production time bundle exec rake assets:precompile --trace

EXIT_STATUS=$?
echo "EXIT STATUS: $EXIT_STATUS"

if [ "$EXIT_STATUS" == "0" ]; then
  github_status success "succeeded on Jenkins"
else
  github_status failure "failed on Jenkins"
fi

exit $EXIT_STATUS
