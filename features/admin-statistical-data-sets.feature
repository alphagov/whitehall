Feature: Adding stastical data set references to a publication
  As a departmental content editor
  In order to reference relevant stastics
  I want to be able to add those references to a publication

  Scenario Outline: Creating a new draft publication that references statistical data sets
    Given I am an editor
    And the document hub feature flag is <document_hub_enabled>
    And a published statistical data set "Historical Beard Lengths"
    When I draft a new publication "Beard Lengths 2012" referencing the data set "Historical Beard Lengths"
    Then the publication should reference the "Historical Beard Lengths" data set

  Examples:
    | document_hub_enabled |
    | enabled |
    | disabled |