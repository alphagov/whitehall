Feature: Standard Editions

  Scenario: Creating a new draft configurable document
    Given I am a writer in the organisation "Department of Examples"
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then I am on the summary page of the draft titled "The history of GOV.UK"

  Scenario: Force publishing an existing draft configurable document
    Given I am a editor in the organisation "Department of Examples"
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I publish a submitted draft of a test configurable document titled "The history of GOV.UK"
    Then I can see that the draft edition of "The history of GOV.UK" was published successfully