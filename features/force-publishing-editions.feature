Feature: Force Publishing editions

  Background:
    Given I am an editor

  @not-quite-as-fake-search
  Scenario Outline: Force-publishing a submitted edition
    Given I draft a new publication "Ban Beards"
    And the document hub feature flag is <document_hub_enabled>
    When I force publish the publication "Ban Beards"
    Then the publication "Ban Beards" should have a force publish reason

  Examples:
    | document_hub_enabled |
    | enabled |
    | disabled |

  Scenario Outline: Retrospective second-pair of eyes
    Given I draft a new publication "Ban Beards"
    And the document hub feature flag is <document_hub_enabled>
    And I force publish the publication "Ban Beards"
    When another editor retrospectively approves the "Ban Beards" publication
    Then the "Ban Beards" publication should not be flagged as force-published any more

  Examples:
    | document_hub_enabled |
    | enabled |
    | disabled |