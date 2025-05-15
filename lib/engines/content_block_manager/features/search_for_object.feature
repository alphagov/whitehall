Feature: Search for a content object
  Background:
    Given I am in the staging or integration environment
    And the organisation "Department of Placeholder" exists
    And the organisation "Ministry of Example" exists
    And I am an admin in the organisation "Department of Placeholder"
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | string | true     |
    And a schema "postal_address" exists with the following fields:
      | field         | type   | format | required |
      | an_address    | string | string | true     |
    And 1 content blocks of type postal_address have been created with the fields:
      | title |  "an address" |
      | an_address  | ABC123 |
      | organisation | Department of Placeholder |
      | instructions_to_publishers | for GDS use only |
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
    Then 'all organisations' is already selected as a filter
    And "3" content blocks are returned in total
    When I select the lead organisation "Department of Placeholder"
    And I click to view results
    Then I should see the details for all documents from my organisation

  @disable_transactions
  Scenario: GDS Editor searches for a content object by keyword in instructions to publishers
    When I visit the Content Block Manager home page
    And I enter the keyword "GDS"
    And I click to view results
    Then I should see the content block with title "an address" returned
    And "1" content blocks are returned in total

  @disable_transactions
  Scenario: GDS Editor searches for a content object by keyword in title
    When I visit the Content Block Manager home page
    And I enter the keyword "example search"
    And I click to view results
    Then I should see the content block with title "example search title" returned
    And "1" content blocks are returned in total

  @disable_transactions
  Scenario: GDS Editor searches for a content object by keyword in details
    When I visit the Content Block Manager home page
    And I enter the keyword "ABC123"
    And I click to view results
    Then I should see the content block with title "an address" returned
    And "1" content blocks are returned in total

  Scenario: GDS Editor searches for a content object by block type
    When I visit the Content Block Manager home page
    And I select the lead organisation "All organisations"
    And I check the block type "Email address"
    And I click to view results
    And "2" content blocks are returned in total

  Scenario: GDS Editor searches for a content object by lead organisation
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    And "1" content blocks are returned in total

  Scenario: GDS Editor searches for a content object by last updated date
    When one of the content blocks was updated 2 days ago
    When I visit the Content Block Manager home page
    And I add a filter for blocks updated two days ago
    And I click to view results
    And "1" content blocks are returned in total

  Scenario: GDS Editor sees errors when searching by invalid dates
    When I visit the Content Block Manager home page
    And I input invalid dates to filter by
    And I click to view results
    Then I should see a message that the filter dates are invalid

  Scenario: GDS Editor can view more than one page
    When 1 content blocks of type email_address have been created with the fields:
      | title | page 2 edition |
      | email_address  | ministry@example.com |
      | organisation | Ministry of Example |
    When 15 content blocks of type email_address have been created with the fields:
      | title | page 1 edition |
      | email_address  | ministry@example.com |
      | organisation | Ministry of Example |
    When I visit the Content Block Manager home page
    And I select the lead organisation "Ministry of Example"
    And I click to view results
    Then I should see the content block with title "page 1 edition" returned
    And I click on page 2
    Then I should see the content block with title "page 2 edition" returned
