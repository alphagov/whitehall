#!/usr/bin/env groovy

library("govuk")

REPOSITORY = 'whitehall'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-whitehall")
  govuk.buildProject(
    sassLint: false,
    publishingE2ETests: true,
    beforeTest: {
      stage("Generate directories for upload tests") {
        sh ("mkdir -p ./incoming-uploads")
        sh ("mkdir -p ./clean-uploads")
        sh ("mkdir -p ./infected-uploads")
        sh ("mkdir -p ./attachment-cache")
        sh ("mkdir -p ./asset-manager-tmp")
      }
    },
    overrideTestTask: {
      stage("Run tests") {
        govuk.withStatsdTiming("test_task") {
          if (params.IS_SCHEMA_TEST) {
            echo "Running a subset of the tests to check the content schema changes"
            govuk.runRakeTask("test:publishing_schemas --trace")
          } else {
            govuk.runRakeTask("ci:setup:minitest test:in_parallel --trace")
          }
        }
      }
    }
  )
}
