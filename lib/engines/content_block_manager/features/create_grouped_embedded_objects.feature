Feature: Create an embedded content object with grouped subschemas

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
    And the schema "contact" has a group "modes" with the following subschemas:
      | email_addresses | telephones |
    And a contact content block has been created

  Scenario: GDS editor creates and edits an email_address
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to add a new "mode"
    Then I should see all the subschemas for "modes" listed
    When I click on the "email_addresses" subschema
    Then I should see a form to create a "email address" for the content block
    When I complete the "email_address" form with the following fields:
      | title   | email_address  |
      | my rate | foo@example.com |
    Then I should be asked to review my "email address"
    When I review and confirm my "email_address" is correct
    Then the "email_address" should have been created successfully
    And I should see confirmation that my "email address" has been created
