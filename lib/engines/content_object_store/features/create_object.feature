Feature: Create a content object

  Background:
    Given the content object store feature flag is enabled
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
    When I visit the document object store
    And I click to create an object
    Then I should see all the schemas listed
    And I should see a back link to the document list page
    When I click on the "email_address" schema
    Then I should see a form for the schema
    And I should see a back link to the select schema page
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | foo@example.com | Somewhere  | Ministry of Example |
    Then I am asked to check my answers
    When I accept and publish
    Then the edition should have been created successfully
    And I should be taken back to the document page

  Scenario: GDS editor sees validation errors when not selecting an object type
    When I visit the document object store
    And I click to create an object
    And I click save
    Then I should see an error prompting me to choose an object type

  Scenario: GDS editor sees validation errors for missing fields
    When I visit the document object store
    And I click to create an object
    When I click on the "email_address" schema
    And I click save
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for invalid fields
    When I visit the document object store
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department | organisation |
      | my email address | xxxxx           | Somewhere  | Ministry of Example |
    Then I should see a message that the "email_address" field is an invalid "email"
