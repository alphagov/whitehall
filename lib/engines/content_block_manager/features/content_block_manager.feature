Feature: Content block manager

  Scenario: Correct layout is used
    Given the content block manager feature flag is enabled
    Given I am a GDS admin
    When I visit the Content Block Manager home page
    Then I should see the object store's title in the header
    And I should see the object store's navigation
