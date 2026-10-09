Feature: Standard Editions

  Scenario: Creating a child document for a parent edition
    Given I am a writer
    And a published standard edition called "Published Edition" exists
    And the configurable document types feature flag is enabled
    When I manually navigate to the 'new document' screen with a parent_edition_id param set
    Then I should see a banner that displays the current parent edition
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then the document should be created
    And I should be on the document summary page for the child document
    And I should see a banner that displays the current parent edition

  Scenario: Error: unable to create a child document for an unknown parent edition
    Given I am a writer
    And the configurable document types feature flag is enabled
    When I manually navigate to a 'new document' screen with an invalid parent_edition_id param set
    And I fill in and submit the form with title 'Some Test Title'
    Then the document should fail to save
    And I should see an error message describing the corrupt parent edition ID

  Scenario: Editing a child document of a parent edition
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    When I edit a child document of that edition
    Then I should see a banner that displays the current parent edition

  Scenario: Seeing the parent edition on a child document's summary page
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    When I view the summary page of a child document of that edition
    Then I should see the parent edition on the summary page

  Scenario: Seeing child pages on a parent edition's summary page
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    When I view the summary page of that edition after adding a child document to it
    Then I should see the child document on the summary page

  Scenario: Seeing other child pages on a child document's summary page
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    When I view the summary page of a child document of that edition that has another child document
    Then I should see the other child document on the summary page
