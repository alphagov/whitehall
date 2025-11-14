Feature: Standard Editions

  Scenario: Creating a new draft configurable document
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I draft a new "Test configurable document type" configurable document titled "The history of GOV.UK"
    Then I am on the summary page of the draft titled "The history of GOV.UK"
    And when I switch to the Images tab to fill in the other configurable fields
    Then the configurable fields on the Images tab are persisted
    And the configurable fields on the Document tab are not overwritten

  Scenario: Force publishing an existing draft configurable document
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined
    When I publish a submitted draft of a test configurable document titled "The history of GOV.UK"
    Then I can see that the draft edition of "The history of GOV.UK" was published successfully
    And a new draft of "The history of GOV.UK" is created with the correct field values

  Scenario: Adding translations with all content block types
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined with translations enabled
    And I have drafted an English configurable document titled "Digital transformation report"
    When I add a Welsh translation "Adroddiad trawsnewid digidol"
    Then configured content blocks should appear on the translation page
    And the Welsh translation fields should be pre-populated with primary locale content
    And the image selections should be preserved from the primary locale
    And I should see the original English content in "original text" sections

  Scenario: Creating a non-English primary locale configurable document
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type is defined with translations enabled
    When I create a new "Test configurable document type" with Welsh as the primary locale titled "Strategaeth Ddigidol Cymru"
    Then I am on the summary page of the draft titled "Strategaeth Ddigidol Cymru"
    And the language of the document should be Welsh

  Scenario: Changing the configurable document type
    Given I am a GDS admin
    And the configurable document types feature flag is enabled
    And the test configurable document type group is defined
    And I have created a new "test_type_1" draft
    Then I should see a 'Change' link in the 'Type of document' row
    And clicking it should take me to a form listing the document types I can switch to
    And choosing a document type should take me to a preview page summarising the changes
    And when I click "Confirm document type change"
    Then the document type should have updated
