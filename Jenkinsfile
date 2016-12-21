#!/usr/bin/env groovy

REPOSITORY = 'whitehall'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: 'whitehall',
      throttleEnabled: true,
      throttleOption: 'category'],
  ])

  try {
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
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency()
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("rubylinter") {
      govuk.rubyLinter('app test lib')
    }

    stage("Set up the DB") {
      sh("RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load")
    }

    stage("Run tests") {
      sh("RAILS_ENV=test bundle exec rake ci:setup:minitest test:in_parallel --trace")
      sh("RAILS_ENV=production GOVUK_ASSET_ROOT=http://static.test.alphagov.co.uk bundle exec rake assets:precompile --trace")
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
