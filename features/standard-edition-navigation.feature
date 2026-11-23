Feature: Standard Edition navigation

  Background:
    Given I am a writer
    And the configurable document types feature flag is enabled

  Scenario: A new standard edition has no child pages to add to its navigation
    When I draft a new "Test configurable document type" configurable document titled "Parent edition"
    Then the document should be created
    When I view the "Navigation" tab of the document titled "Parent edition"
    Then I see the "There are no child pages." message
    And I should not see the "Add navigation menu" button

  Scenario: A standard edition with a child page can have a navigation menu
    Given a draft standard edition called "Parent edition" exists
    When I add a new child page titled "Child edition" to the edition
    And I view the "Navigation" tab
    Then I should see the "Add navigation menu" button

  Scenario: Adding child pages to the navigation of a standard edition
    Given a draft standard edition called "Parent edition" exists
    And the edition has child pages titled "First child edition", "Second child edition" and "Third child edition"
    Then I should see "First child edition", "Second child edition" and "Third child edition" as options in the navigation form
    When I add "First child edition" and "Third child edition" to the navigation of the edition
    And I view the "Navigation" tab
    Then I should see "First child edition" and "Third child edition" in the navigation table
    And I should not see "Second child edition" in the navigation table
