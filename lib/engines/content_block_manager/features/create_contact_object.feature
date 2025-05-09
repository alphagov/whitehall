Feature: Create a contact object

  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "contact" exists with the following fields:
      | field         | type   | format | required |
      | description   | string | string | true     |
    And the schema "contact" has a subschema with the name "email_addresses" and the following fields:
      | field            | type   | format | required | enum           | pattern          |
      | title            | string | string | true     |                |                  |
      | email_address    | string | string | true     |                |                  |
    And the schema "contact" has a subschema with the name "telephones" and the following fields:
      | field     | type   | format | required | enum           | pattern          |
      | title     | string | string | true     |                |                  |
      | telephone | string | string | true     |                |                  |
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic contact | this is basic | Ministry of Example | this is important  |

  Scenario: GDS editor creates a Contact without any embedded objects
    When I save and continue
    Then I am asked to review my answers for a "contact"
    And I review and confirm my answers are correct
    Then the edition should have been created successfully
    And I should be taken to the confirmation page for a new "contact"

  Scenario: GDS editor creates a Contact with an email address and a telephone
    When I click to add a new "email_address"
    And I complete the "email_address" form with the following fields:
      | title     | email_address          |
      | New email | foo@example.com        |
    When I click to add a new "telephone"
    And I complete the "telephone" form with the following fields:
      | title            | telephone |
      | New phone number | 123456    |
    Then I should be on the "embedded_objects" step
    When I save and continue
    And I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a new "contact"
