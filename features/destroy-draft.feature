Feature: Discarding a draft of a document
  As a writer
  I can discard the draft of a document
  So that the document will not appear in the list of draft documents

  Scenario: Unwithdrawing a withdrawn document
    Given I am a writer
    When I draft a new publication "My Publication"
    And I discard the draft publication
    Then the publication is deleted

  Scenario: Unwithdrawing a withdrawn document with design system permission
    Given I am a writer
    And I have the "Preview design system" permission
    When I draft a new publication "My Publication"
    And I discard the draft publication
    Then the publication is deleted
