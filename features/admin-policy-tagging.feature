Feature: Tagging content with policies
  As a departmental content editor
  In order to make content available to users interested in a related policy
  I want to be able to tag content to one or more policy areas or programmes

  This feature relates to the new-world policy programes and policy areas that
  are created and managed in policy-publisher and stored in the content store.
  These policies will eventually replace the Policy format here in whitehall.

  Scenario: a writer can tag a document to a policy
    Given I am a writer
    When I start editing a draft document
    And I continue to the tagging page
    Then I can tag the edition to some policies

  Scenario: a writer can tag a topic to a policy
    Given I am a writer
    When I start creating a topic
    Then I can tag the topic to some policies
