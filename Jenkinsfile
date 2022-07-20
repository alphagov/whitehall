#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'whitehall'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-whitehall")
  govuk.setEnvar("TEST_DATABASE_URL", "mysql2://root:root@127.0.0.1:33068/whitehall_test")
  govuk.buildProject(
    publishingE2ETests: true,
    brakeman: true,
    overrideTestTask: {
      stage("Run tests") {
        if (params.IS_SCHEMA_TEST) {
          echo "Running a subset of the tests to check the content schema changes"
          govuk.runRakeTask("test:publishing_schemas --trace")
        } else {
          sh("bundle exec rake")
        }
      }
    }
  )
}
