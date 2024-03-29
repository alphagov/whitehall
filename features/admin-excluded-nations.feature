Feature: Marking a publication with excluded nations
  As a departmental content editor
  In order to increase the relevancy of content to users
  I want to be able to exclude content from one or more nation

  Scenario Outline: Creating a new draft publication that applies to multiple nations
    Given I am a writer
    And the document hub feature flag is <document_hub_enabled>
    When I draft a new publication "something" that does not apply to the nations:
      | Scotland | Wales |
    Then the publication should be excluded from these nations:
      | Scotland | Wales |

  Examples:
    | document_hub_enabled |
    | enabled |
    | disabled |