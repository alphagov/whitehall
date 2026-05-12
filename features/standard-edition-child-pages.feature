Feature: Standard Editions - Child Pages

  Scenario: Creating a new draft configurable document
    Given I am a writer
    And the configurable document types feature flag is enabled
    And the test configurable document type group is defined
    When I draft a new parent configurable document
    Then I should see a "Child documents" section on the document summary page
    And when I click the link "Add child document"
    Then I am taken to the new child document page
    And I see only the relevant child document types
    And when I choose a child document type
    Then I am on the document creation screen
    And I can see a "You are creating a child document" callout
    And when I fill in and create the child document
    Then I am taken to the summary page of my child document
    And I can see a "This is a child document" callout
    And it links back to the parent document

  Scenario: Not able to create a child document from a parent in a published state
    Given I am a writer
    And the configurable document types feature flag is enabled
    And the test configurable document type group is defined
    And I have a published parent configurable document
    Then I should see a "Child documents" section on the document summary page
    And there should be no "Add child document" link

  Scenario: Not able to delete a draft parent if it contains any non-live children
    Given I am a writer
    And the configurable document types feature flag is enabled
    And the test configurable document type group is defined
    And I have drafted a parent and a child configurable document
    Then when I click the link "Delete draft"
    And when I click "Delete"
    Then I should get the error message "This document cannot be deleted while it has child documents that have never been published. Delete the draft child documents first."

  Scenario: Child publishability
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type group is defined
    And I have drafted a parent and a child configurable document
    Then I should see no option to publish the child
    But when I publish the parent
    Then I should be able to publish the child
