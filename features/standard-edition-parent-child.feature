Feature: Standard Editions

  Scenario: Creating a child document for a parent edition
    Given I am a writer
    And a published standard edition called "Published Edition" exists
    And the configurable document types feature flag is enabled
    When I manually navigate to the 'new document' screen with a parent_edition_id param set
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then the document should be created
    And the document should be designated a child of the parent document

  Scenario: Error: unable to create a child document for an unknown parent edition
    Given I am a writer
    And the configurable document types feature flag is enabled
    When I manually navigate to a 'new document' screen with an invalid parent_edition_id param set
    And I fill in and submit the form with title 'Some Test Title'
    Then the document should fail to save
    And I should see an error message describing the corrupt parent edition ID
