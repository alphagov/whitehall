Feature: Create a content object when feature flag is disabled

  Background:
    Given the content block manager feature flag is disabled
    Given I am a GDS admin

  Scenario: GDS editor visits object store
    When I visit the Content Block Manager home page
    Then I should see a permissions error
