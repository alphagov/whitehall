Feature: View a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | email_address |
    And an email address content block has been created

  Scenario: GDS Editor views a content object
    When I visit the Content Block Manager home page
    Then I should see the details for all documents
    When I click to view the document
    Then I should be taken back to the document page
    And I should see the details for the email address content block
    And I should see 1 publish events on the timeline

  Scenario: GDS Editor views dependent Content
    Given dependent content exists for a content block
    When I visit the Content Block Manager home page
    And I click to view the document
    Then I should see the dependent content listed

