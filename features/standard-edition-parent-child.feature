Feature: Standard Editions

  Scenario: Creating a child document for a parent edition
    Given I am a writer
    And a published standard edition called "Published Edition" exists
    And the configurable document types feature flag is enabled
    When I manually navigate to the 'new document' screen with a parent_edition_id param set
    Then I should see a banner that displays the current parent edition
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then the document should be created
    Then I should see a banner that displays the current parent edition

  Scenario: Error: unable to create a child document for an unknown parent edition
    Given I am a writer
    And the configurable document types feature flag is enabled
    When I manually navigate to a 'new document' screen with an invalid parent_edition_id param set
    And I fill in and submit the form with title 'Some Test Title'
    Then the document should fail to save
    And I should see an error message describing the corrupt parent edition ID

  Scenario: Editing a child document for a parent edition
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    And a draft configurable document called "Child Edition" exists which is a child of "Parent Edition" 
    When I visit the document summary page of the standard edition called "Child Edition"
    Then I should see a banner that displays the parent edition titled "Parent Edition"
    When I edit the standard edition called "Child Edition"
    Then I should see a banner that displays the parent edition titled "Parent Edition"

  Scenario: Editing a document that is not a child document for a parent edition
    Given I am a writer
    And a published standard edition called "Parent Edition" exists
    And a published standard edition called "Unrelated Edition" exists
    When I visit the document summary page of the standard edition called "Unrelated Edition" with a parent_edition_id param of "Parent Edition" set
    Then I should not see a banner that displays the parent edition titled "Parent Edition"