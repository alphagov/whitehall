Feature: Viewing locked documents
  Scenario: Locked document appears on index page
    Given a published locked document titled "A document that will be migrated"
    When I visit the list of published documents
    Then I should see the document "A document that will be migrated" in the list of published documents
    And I can see that the document has been moved to Content Publisher
