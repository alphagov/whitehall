Feature: Create a content object

  Background:
    Given the content object store feature flag is enabled
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
      | field         | type   | format | required |
      | email_address | string | email  | true     |
      | department    | string |        | true     |
    And a schema "tax_rates" exists with the following fields:
      | field         | type   | format | required |
      | rate          | string |        | true     |

  Scenario: GDS editor creates an object
    When I visit the object store
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department |
      | my email address | foo@example.com | Somewhere  |
    Then the edition should have been created successfully

  Scenario: GDS editor sees validation errors for missing fields
    When I visit the object store
    And I click to create an object
    When I click on the "email_address" schema
    And I click save
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for invalid fields
    When I visit the object store
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | email_address   | department |
      | my email address | xxxxx           | Somewhere  |
    Then I should see a message that the "email_address" field is an invalid "email"
