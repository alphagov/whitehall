Feature: Search for a content object
  Background:
    Given the content block manager feature flag is enabled
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | email_address |
    And an email address content block has been created
    And an email address content block has been created with the title "example search title"

  Scenario: GDS Editor searches for a content object by keyword in title
    When I visit the Content Block Manager home page
    Then I should see the details for all documents
    And "2" content blocks are returned
    When I enter the title "example search"
    And I click to view results
    Then I should see the content block with title "example search title" returned
    And "1" content blocks are returned