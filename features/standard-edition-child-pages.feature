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
