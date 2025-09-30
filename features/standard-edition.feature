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
    When I create a new configurable document with Welsh as the primary locale titled "Strategaeth Ddigidol Cymru"
    Then the document should be saved with Welsh as the primary locale
    And English should not appear as a translation option


