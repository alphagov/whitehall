Feature: Viewing locked documents
  Background:
    Given a document titled "A document that will be migrated"

  Scenario: Locked document appears on index page
    And the document is locked
    When I visit the list of published documents
    Then I should see the document "A document that will be migrated" in the list of published documents
