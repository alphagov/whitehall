#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'whitehall'
DEFAULT_SCHEMA_BRANCH = 'main'

node {
  govuk.setEnvar("TEST_DATABASE_URL", "mysql2://root:root@127.0.0.1:33068/whitehall_test")
  govuk.setEnvar("REDIS_URL", "redis://127.0.0.1:63796")
  govuk.buildProject(
    brakeman: true,
    overrideTestTask: {
      stage("Run tests") {
        if (params.IS_SCHEMA_TEST) {
          echo "Running a subset of the tests to check the content schema changes"
          govuk.runRakeTask("test:publishing_schemas --trace")
        } else {
          sh("bundle exec rake lint test cucumber jasmine")
        }
      }
    }
  )
}
