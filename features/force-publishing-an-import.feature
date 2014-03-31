@import
Feature: Force publishing an import
  As an importer
  I want to be able to force publish an imported batch of documents when it's ready
  So that I don't have to go through each document individually

  This means:
  - should only be able to force-publish if none in the batch are in 'imported' state
  - won't try to publish any imported editions that are in the 'deleted' state
  - won't try to publish any imported editions that are already 'published'
  - won't try to publish any new drafts created after the imported one
  - will act as the "GDS Inside Government Team" user
  - the log output of this process is recorded and made available

  Background:
    Given I am an importer

  Scenario: Can't force publish a failed import
    Given I have imported a file that failed
    Then I cannot force publish the import

  Scenario: Can't force publish a successful import with imported editions
    Given I have imported a file that succeeded
    Then I cannot force publish the import
    When I speed tag some of the documents and make them draft
    Then I cannot force publish the import

  Scenario: Force publishing a successful import after speed-tagging
    Given I have imported a file that succeeded
    When I speed tag all of the documents and make them draft
    And I force publish the import
    Then I cannot force publish the import again
    And I can see the log output of the force publish for my import
    And my imported documents are published
