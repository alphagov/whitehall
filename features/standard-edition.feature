Feature: Standard Editions

  Scenario: Creating a new draft configurable document
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then I am on the summary page of the draft titled "The history of GOV.UK"

  Scenario: Force publishing an existing draft configurable document
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I publish a submitted draft of a test configurable document titled "The history of GOV.UK"
    Then I can see that the draft edition of "The history of GOV.UK" was published successfully
    And a new draft of "The history of GOV.UK" is created with the correct field values
