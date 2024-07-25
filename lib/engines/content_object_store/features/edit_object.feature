Feature: Edit a content object
  Background:
    Given the content object store feature flag is enabled

  Scenario: GDS Editor edits a content object
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the document object store
    Then I should see the details for all documents
    When I click to view the document
    Then I should see the details for the email address content block
    When I click the first change link
    Then I should see the edit form
    And I should see a back link to the document page
    When I fill out the form
    Then the edition should have been updated successfully
    And I should be taken back to the document page

  Scenario: GDS editor sees validation errors for missing fields
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
    | field         | type   | format | required |
    | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the document object store
    When I click to view the document
    When I click the first change link
    And I set all fields to blank
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for invalid fields
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
    | field         | type   | format | required |
    | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the document object store
    When I click to view the document
    When I click the first change link
    When I complete the form with the following fields:
    | title            | email_address   |
    | my email address | xxxxx           |
    Then I should see a message that the "email_address" field is an invalid "email"
