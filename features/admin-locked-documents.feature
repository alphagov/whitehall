Feature: Viewing locked documents
  Scenario: Locked document appears on index page
    Given a published locked document titled "A document that will be migrated"
    When I visit the list of published documents
    Then I should see the document "A document that will be migrated" in the list of published documents

  Scenario: Published locked document admin page
    Given a published locked document titled "A document that will be migrated"
    When I visit the admin page for "A document that will be migrated"
    Then I can see that I cannot create a new draft
    And I can see that the document has been moved to Content Publisher

  Scenario: Draft locked document admin page
    Given a draft locked document titled "A document that will be migrated"
    When I visit the admin page for "A document that will be migrated"
    Then I can see that the document cannot be edited
    And I can see that the document has been moved to Content Publisher
