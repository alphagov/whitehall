Feature: List of most recently published documents
  So that I can …
  As a user
  I want to be able to see the most recently published content by an
  organisation or about a topic, topical event or world location

  Scenario: Latest documents on topical event page
    Given a topical event with published documents
    When I view that topical event page
    Then I can see some of the latest documents
    And I can follow a link to see all documents

  Scenario: List of all documents published about a topical event
    Given a topical event with published documents
    When I view the list of all documents for that topical event
    Then I see all documents for that topical event with the most recent first
    And I can see a link back to the topical event page
    And I can see links to get alerts
