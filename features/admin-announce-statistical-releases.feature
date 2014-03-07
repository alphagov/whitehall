Feature: Announcing a upcoming statistical release

  As an publisher of government statistics
  I want to be able to announce upcoming statistical publications
  So that citizens can see which statistical publications are coming soon and when they will be published.

  Scenario: announcing a upcoming statistics publication
    Given I am a writer in the organisation "Department for Beards"
    When I announce an upcoming statistics publication called "Monthly Beard Stats"
    Then I should see "Monthly Beard Stats" listed as an announced document on my dashboard

  Scenario: drafting a document from a statistical release announcement
    Given I am a editor in the organisation "Department for Beards"
    And a statistical release announcement called "Monthly Beard Stats" exists
    When I go to draft a statistics document from the announcement
    Then the document fields are pre-filled based on the announcement
    When I save the draft statistics document
    Then the document becomes linked to the announcement
