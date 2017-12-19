#!/usr/bin/env groovy

REPOSITORY = 'whitehall'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: DEFAULT_SCHEMA_BRANCH,
          description: 'The branch of govuk-content-schemas to test against']]
    ],
  ])

  try {
    if (!govuk.isAllowedBranchBuild(env.BRANCH_NAME)) {
      return
    }

    stage("Checkout") {
      checkout scm
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("git merge") {
      govuk.mergeMasterBranch()
    }

    stage("Generate directories for upload tests") {
      sh ("mkdir -p ./incoming-uploads")
      sh ("mkdir -p ./clean-uploads")
      sh ("mkdir -p ./infected-uploads")
      sh ("mkdir -p ./attachment-cache")
      sh ("mkdir -p ./asset-manager-tmp")
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency(params.SCHEMA_BRANCH)
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("rubylinter") {
      govuk.rubyLinter('app test lib')
    }

    stage("Configure environment") {
      govuk.setEnvar("DISABLE_DATABASE_ENVIRONMENT_CHECK", "1")
      govuk.setEnvar("RAILS_ENV", "test")
      govuk.setEnvar("RACK_ENV", "test")
      govuk.setEnvar("DISPLAY", ":99")
    }

    lock ("whitehall-$NODE_NAME-test") {
      stage("Set up the DB") {
        sh("RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load")
      }

      stage("Run tests") {
        govuk.setEnvar("RAILS_ENV", "test")
        if (params.IS_SCHEMA_TEST) {
          echo "Running a subset of the tests to check the content schema changes"
          govuk.runRakeTask("test:publishing_schemas --trace")
        } else {
          govuk.runRakeTask("ci:setup:minitest test:in_parallel --trace")
        }
      }
    }

    stage("Build Docker image") {
      govuk.buildDockerImage(REPOSITORY, env.BRANCH_NAME)
    }

    stage("Push Docker image") {
      govuk.pushDockerImage(REPOSITORY, env.BRANCH_NAME)
    }

    stage("Precompile assets") {
      if (params.IS_SCHEMA_TEST) {
        echo "Skipping precompile step because this is a schema test"
      } else {
        sh("RAILS_ENV=production GOVUK_APP_DOMAIN=test.gov.uk GOVUK_ASSET_ROOT=https://static.test.gov.uk GOVUK_ASSET_HOST=https://static.test.gov.uk bundle exec rake assets:precompile --trace")
      }
    }

    if (env.BRANCH_NAME == 'master') {
      stage("Push release tag") {
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, 'release_' + env.BUILD_NUMBER)
      }

      govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
