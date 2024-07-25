Feature: Create a content object when feature flag is disabled

  Background:
    Given the content object store feature flag is disabled
    Given I am a GDS admin

  Scenario: GDS editor visits object store
    When I visit the document object store
    Then I should see a permissions error
