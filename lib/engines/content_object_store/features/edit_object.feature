Feature: Edit a content object

  Scenario: GDS Editor edits a content object
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the object store
    Then I should see the details for all content blocks
    When I click to view the content block
    Then I should see the details for the email address content block
    When I click the first change link
    Then I should see the edit form
    When I fill out the form
    Then the edition should have been updated successfully
