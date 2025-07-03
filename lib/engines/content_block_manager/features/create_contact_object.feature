Feature: Create a contact object

  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "contact" exists:
    """
    {
       "type":"object",
       "required":[
          "description"
       ],
       "additionalProperties":false,
       "properties":{
          "description": {
            "type": "string"
          }
       }
    }
    """
    And the schema has a subschema "email_addresses":
    """
    {
      "type":"object",
      "required": ["title", "email_address"],
      "properties": {
        "title": {
          "type": "string"
        },
        "email_address": {
          "type": "string"
        }
      }
    }
    """
    And the schema has a subschema "telephones":
    """
    {
      "type":"object",
      "required": [
        "title",
        "telephone_numbers",
        "show_uk_call_charges"
      ],
      "properties": {
        "telephone_numbers": {
          "type": "array",
          "items": {
            "type": "object",
            "required": [
              "type",
              "label",
              "telephone_number"
            ],
            "properties": {
              "label": {
                "type": "string"
              },
              "telephone_number": {
                "type": "string"
              },
              "type": {
                "type": "string",
                "enum": [
                  "",
                  "telephone",
                  "textphone"
                ]
              }
            }
          }
        },
        "title": {
          "type": "string"
        },
        "show_uk_call_charges": {
          "type": "string",
          "enum": [
            "true",
            "false"
          ]
        },
        "opening_hours": {
          "type": "array",
          "items": {
            "type": "object",
            "required": [
              "day_from",
              "day_to",
              "time_from",
              "time_to"
            ],
            "properties": {
              "day_from": {
                "type": "string"
              },
              "day_to": {
                "type": "string"
              },
              "time_from": {
                "type": "string",
                "pattern": "^[0-9]{1,2}:[0-9]{2}AM|PM$"
              },
              "time_to": {
                "type": "string",
                "pattern": "^[0-9]{1,2}:[0-9]{2}AM|PM$"
              }
            }
          }
        }
      }
    }
    """
    And the schema "contact" has a group "modes" with the following subschemas:
      | email_addresses | telephones |
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "contact" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic contact | this is basic | Ministry of Example | this is important  |

  @javascript
  Scenario: GDS editor creates a Contact with an email address and a telephone
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | email_address          |
      | New email | foo@example.com        |
    And I click to add another "mode"
    And I click on the "telephones" subschema
    And I fill in the "telephone" form with the following fields:
      | title            |
      | New phone number |
    And I add the following "telephone_numbers" to the form:
      | label       | telephone_number | type      |
      | Telephone 1 | 12345            | Telephone |
      | Telephone 2 | 6789             | Textphone |
    And I add the following "opening_hours" to the form:
      | day_from | day_to | time_from | time_to |
      | Monday   | Friday | 9:00AM    | 5:00PM  |
      | Saturday | Sunday  | 10:00AM   | 3:00PM  |
    And I save and continue
    Then I should be on the "add_group_modes" step
    When I save and continue
    And I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a new "contact"
    When I click to view the content block
    And I should see the created embedded object of type "email_address"
    And I should see the created embedded object of type "telephone"

  @javascript
  Scenario: GDS editor sees errors for invalid telephone objects
    When I save and continue
    And I click on the "telephones" subschema
    When I save and continue
    Then I should see errors for the required nested "telephone_number" fields

  @javascript
  Scenario: Telephone number label is automatically populated
    When I click on the "telephones" subschema
    And I choose "Textphone" from the type dropdown
    Then the label should be set to "Textphone"

  Scenario: GDS editor edits answers during creation of an object
    And I click on the "email_addresses" subschema
    And I complete the "email_address" form with the following fields:
      | title     | email_address          |
      | New email | foo@example.com        |
    And I save and continue
    When I click the first edit link
    And I complete the form with the following fields:
      | title            |
      | New email 2 |
    And I save and continue
    Then I am asked to review my answers
    And I confirm my answers are correct
    And I review and confirm my answers are correct
    And I should be taken to the confirmation page for a new "contact"
