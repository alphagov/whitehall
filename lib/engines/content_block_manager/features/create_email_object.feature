Feature: Create a content object

  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
      | department    | string |        | true     |
    And a schema "tax_rates" exists with the following fields:
      | field         | type   | format | required |
      | rate          | string |        | true     |

  Scenario: GDS editor creates an object
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    And I should see a back link to the document list page
    And I should see a Cancel button to the document list page
    When I click on the "email_address" schema
    Then I should see a form for the schema
    And I should see a back link to the select schema page
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation        | instructions_to_publishers |
      | my email address | foo@example.com | Somewhere  | Ministry of Example | this is important  |
    Then I am asked to review my answers
    And I should see a back link to the "edit_draft" step
    When I review and confirm my answers are correct
    Then the edition should have been created successfully
    And I should be taken to the confirmation page for a new block

  Scenario: GDS editor sees validation errors when not selecting an object type
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click save
    Then I should see an error prompting me to choose an object type

  Scenario: GDS editor sees validation errors for missing fields
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "email_address" schema
    And I click save
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for invalid fields
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | xxxxx           | Somewhere  | Ministry of Example |
    Then I should see a message that the field is an invalid "Email address"

  Scenario: GDS editor sees validation errors for unconfirmed answers
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | foo@example.com           | Somewhere  | Ministry of Example |
    Then I am asked to review my answers
    When I click publish without confirming my details
    Then I should see a message that I need to confirm the details are correct

  Scenario: GDS editor does not see error when not providing instructions to publishers
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "email_address" schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation        |
      | my email address | foo@example.com | Somewhere  | Ministry of Example |
    Then I am asked to review my answers

  Scenario: GDS editor cancels the creation of an object
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "email_address" schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | foo@example.com | Somewhere  | Ministry of Example |
    And I click cancel
    Then I am taken back to Content Block Manager home page
    And no draft Content Block Edition has been created
    And no draft Content Block Document has been created

  Scenario: GDS editor edits answers during creation of an object
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "email_address" schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | foo@example.com | Somewhere  | Ministry of Example |
    Then I am asked to review my answers
    When I click the first edit link
    And I complete the form with the following fields:
      | title            |
      | my email address 2 |
    Then I am asked to review my answers
    And I confirm my answers are correct
    And I review and confirm my answers are correct
    And I should be taken to the confirmation page for a new block

  Scenario: Draft documents are not listed
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | foo@example.com | Somewhere  | Ministry of Example |
    And I visit the Content Block Manager home page
    Then I should not see the draft document
