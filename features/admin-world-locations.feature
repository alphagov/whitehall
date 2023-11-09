Feature: Tagging world locations to publications
  As a departmental content editor
  In order to show which location a publication is about
  I want to be able to tag world locations to publications

  Scenario Outline: The publication is about a country
    Given I am an editor
    And the document hub feature flag is <document_hub_enabled>
    And a world location "British Antarctic Territory" exists
    When I draft a new publication "Penguins have rights too" about the world location "British Antarctic Territory"
    Then the publication should be about the "British Antarctic Territory" world location

  Examples:
    | document_hub_enabled |
    | enabled |
    | disabled |