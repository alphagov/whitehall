Feature: Content object store

  Scenario: Correct layout is used
    Given the content object store feature flag is enabled
    Given I am a GDS admin
    When I visit the document object store
    Then I should see the object store's title in the header
    And I should see the object store's navigation
