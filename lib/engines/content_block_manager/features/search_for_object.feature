Feature: Search for a content object
  Background:
    Given I am in the staging or integration environment
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And I am an admin in the organisation "Department of Placeholder"
    And a schema "email_address" exists with the following fields:
      | email_address |
    And a schema "postal_address" exists with the following fields:
      | an_address |
    And 1 content blocks of type postal_address have been created with the fields:
      | title |  "an address" |
      | an_address  | ABC123 |
      | organisation | Department of Placeholder |
    And 1 content blocks of type email_address have been created with the fields:
      | title | example search title |
      | email_address  | hello@example.com |
      | organisation | Department of Placeholder |
    And 1 content blocks of type email_address have been created with the fields:
      | title | ministry address |
      | email_address  | ministry@example.com |
      | organisation | Ministry of Example |

  Scenario: GDS Editor can filter by organisation
    When I visit the Content Block Manager home page
    Then my organisation is already selected as a filter
    And I should see the details for all documents from my organisation
    When I select the lead organisation "All organisations"
    And I click to view results
    Then "3" content blocks are returned

  Scenario: GDS Editor searches for a content object by keyword in title
    When I visit the Content Block Manager home page
    And I enter the keyword "example search"
    And I click to view results
    Then I should see the content block with title "example search title" returned
    And "1" content blocks are returned

  Scenario: GDS Editor searches for a content object by keyword in details
    When I visit the Content Block Manager home page
    And I enter the keyword "ABC123"
    And I click to view results
    Then I should see the content block with title "an address" returned
    And "1" content blocks are returned

  Scenario: GDS Editor searches for a content object by block type
    When I visit the Content Block Manager home page
    And I select the lead organisation "All organisations"
    And I check the block type "Email address"
    And I click to view results
    And "2" content blocks are returned

  Scenario: GDS Editor searches for a content object by lead organisation
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    And "1" content blocks are returned

  @javascript
  Scenario: GDS Editor can copy embed code
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    And I click to copy the embed code for the content block "ministry address"
    Then the embed code should be copied to my clipboard

  Scenario: GDS Editor can view more than one page
    When 15 content blocks of type email_address have been created with the fields:
      | title | ministry address |
      | email_address  | ministry@example.com |
      | organisation | Ministry of Example |
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    And I click on page 2
    Then "1" content blocks are returned
