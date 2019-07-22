Feature: Viewing locked documents
  Background:
    Given a locked document titled "A document that will be migrated"

  Scenario: Locked document appears on index page
    When I visit the list of published documents
    Then I should see the document "A document that will be migrated" in the list of published documents
