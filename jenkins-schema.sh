#!/bin/bash -xe
export DISPLAY=:99
env

function github_status {
  STATUS="$1"
  MESSAGE="$2"
  gh-status alphagov/govuk-content-schemas "$SCHEMA_GIT_COMMIT" "$STATUS" -d "Build #${BUILD_NUMBER} ${MESSAGE}" -u "$BUILD_URL" -c "Verify whitehall against content schemas" >/dev/null
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

# Clone govuk-content-schemas dependency for contract tests
rm -rf tmp/govuk-content-schemas
git clone git@github.com:alphagov/govuk-content-schemas.git tmp/govuk-content-schemas
cd tmp/govuk-content-schemas
git checkout $SCHEMA_GIT_COMMIT
cd ../..

time bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
RAILS_ENV=test GOVUK_CONTENT_SCHEMAS_PATH=tmp/govuk-content-schemas time bundle exec rake test:publishing_schemas --trace

EXIT_STATUS=$?
echo "EXIT STATUS: $EXIT_STATUS"

if [ "$EXIT_STATUS" == "0" ]; then
  github_status success "succeeded on Jenkins"
else
  github_status failure "failed on Jenkins"
fi

exit $EXIT_STATUS
