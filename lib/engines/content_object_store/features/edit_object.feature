Feature: Edit a content object
  Background:
    Given the content object store feature flag is enabled
    And I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created
    And dependent content exists for a content block

  Scenario: GDS Editor edits a content object
    When I visit the document object store
    Then I should see the details for all documents
    When I click to view the document
    Then I should see the details for the email address content block
    When I click the first change link
    Then I should see the edit form
    And I should see a back link to the document page
    When I fill out the form
    Then I am shown where the changes will take place
    And I should see a back link to the edit page
    When I save and continue
    Then I am asked when I want to publish the change
    And I should see a back link to the review page
    When I choose to publish the change now
    And I accept and publish
    Then the edition should have been updated successfully
    And I should be taken back to the document page
    And I should see 2 publish events on the timeline

  Scenario: GDS editor sees validation errors for missing fields
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
    And a schema "email_address" exists with the following fields:
    | field         | type   | format | required |
    | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the document object store
    When I click to view the document
    When I click the first change link
    When I complete the form with the following fields:
    | title            | email_address   | organisation |
    | my email address | xxxxx           | Ministry of Example |
    Then I should see a message that the "email_address" field is an invalid "email"

  Scenario: GDS editor can override a previously scheduled object
    When I am updating a content block
    And I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    When I revisit the edit page
    Then I should see a warning telling me there is a scheduled change
    When I make the changes
    And I choose to publish the change now
    And I accept and publish
    Then the edition should have been updated successfully

  Scenario: GDS editor still sees live edition when abandoning an edit
    When I am updating a content block
    And I visit the document object store
    Then I should still see the live edition on the homepage

