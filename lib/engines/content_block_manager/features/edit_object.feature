Feature: Edit a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
    And an email address content block has been created
    And dependent content exists for a content block

  Scenario: GDS Editor edits a content object
    When I visit the Content Block Manager home page
    Then I should see the details for all documents
    When I click to view the document
    Then I should see the details for the email address content block
    When I click the first edit link
    Then I should see the edit form
    And I should see a back link to the document page
    When I fill out the form
    Then I am shown where the changes will take place
    And I see the rollup data for the dependent content
    And I should see a back link to the edit page
    When I save and continue
    Then I am asked when I want to publish the change
    And I should see a back link to the review page
    When I choose to publish the change now
    And I save and continue
    When I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a published block
    When I click to view the content block
    Then the edition should have been updated successfully
    And I should be taken back to the document page
    And I should see 2 publish events on the timeline

  Scenario: GDS editor cancels the creation of an object when reviewing links
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    Then I should see the edit form
    When I fill out the form
    Then I am shown where the changes will take place
    And I see the rollup data for the dependent content
    And I click cancel
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  Scenario: GDS editor cancels the creation of an object before scheduling
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    Then I should see the edit form
    When I fill out the form
    Then I am shown where the changes will take place
    And I see the rollup data for the dependent content
    When I save and continue
    Then I am asked when I want to publish the change
    And I click cancel
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  Scenario: GDS editor cancels the creation of an object before confirming answers
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    When I fill out the form
    When I save and continue
    When I choose to publish the change now
    And I save and continue
    And I click cancel
    Then I am taken back to Content Block Manager home page
    And no draft Content Block Edition has been created

  Scenario: GDS editor sees validation errors for missing fields
    And a schema "email_address" exists with the following fields:
    | field         | type   | format | required |
    | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    And I set all fields to blank
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for invalid fields
    And a schema "email_address" exists with the following fields:
    | field         | type   | format | required |
    | email_address | string | email  | true     |
    And an email address content block has been created
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    When I complete the form with the following fields:
    | title            | email_address   | organisation |
    | my email address | xxxxx           | Ministry of Example |
    Then I should see a message that the field is an invalid "Email address"

  Scenario: GDS editor sees validation errors for unconfirmed answers
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click the first edit link
    When I fill out the form
    Then I am shown where the changes will take place
    When I save and continue
    And I choose to publish the change now
    When I save and continue
    Then I am asked to review my answers
    When I click confirm
    Then I should see a message that I need to confirm the details are correct

  @enable-sidekiq-test-mode
  Scenario: GDS editor can override a previously scheduled object
    When I am updating a content block
    And I am asked when I want to publish the change
    And I schedule the change for 7 days in the future
    When I review and confirm my answers are correct
    When I revisit the edit page
    Then I should see a warning telling me there is a scheduled change
    When I make the changes
    And I choose to publish the change now
    And I save and continue
    When I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a published block
    When I click to view the content block
    Then the edition should have been updated successfully

  Scenario: GDS editor still sees live edition when abandoning an edit
    When I am updating a content block
    And I visit the Content Block Manager home page
    Then I should still see the live edition on the homepage

  @javascript
  Scenario: GDS editor can preview a host document
    When I revisit the edit page
    And I fill out the form
    Then I am shown where the changes will take place
    And I see the rollup data for the dependent content
    When I click on the first host document
    Then the preview page opens in a new tab
    When I click on a link within the frame
    Then I should see the content of the linked page
