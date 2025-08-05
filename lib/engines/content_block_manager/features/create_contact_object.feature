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
        "label": {
          "type": "string"
        },
        "email_address": {
          "type": "string"
        },
        "subject": {
          "type": "string"
        },
        "body": {
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
        "telephone_numbers"
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
        "video_relay_service": {
          "type": "object",
          "properties": {
            "show": {
              "type": "boolean",
              "default": false
            },
            "prefix": {
              "type": "string",
              "default": "**Default** prefix: 18000 then"
            },
            "telephone_number": {
              "type": "string",
              "default": "0800 123 4567"
            }
          }
        },
        "call_charges": {
          "type": "object",
          "properties": {
            "label": {
              "type": "string",
              "default": "Find out about call charges"
            },
            "call_charges_info_url": {
              "type": "string",
              "default": "https://gov.uk/call-charges"
            },
            "show_call_charges_info_url": {
              "type": "boolean",
              "default": false
            }
          }
        },
        "bsl_guidance": {
          "type": "object",
          "properties": {
            "show": {
              "type": "boolean",
              "default": false
            },
            "value": {
              "type": "string",
              "default": "British Sign Language (BSL) [video relay service](https://connect.interpreterslive.co.uk/vrs?ilc=DWP)> if you’re on a computer - find out how to [use the service on mobile or tablet](https://www.youtube.com/watch?v=oELNMfAvDxw)"
            }
          }
        },
        "opening_hours": {
          "type": "object",
          "properties": {
            "opening_hours": {
              "type": "string"
            },
            "show_opening_hours": {
              "type": "boolean",
              "default": false
            }
          },
          "if": {
            "properties": {
              "show_opening_hours": {
                "const": true
              }
            }
          },
          "then": {
            "required": [
              "opening_hours"
            ]
          },
          "else": {
            "required": []
          }
        }
      }
    }
    """
    And the schema has a subschema "contact_links":
    """
    {
      "type":"object",
      "required": ["url"],
      "properties": {
        "title": {
          "type": "string"
        },
        "label": {
          "type": "string"
        },
        "url": {
          "type": "string"
        },
        "description": {
          "type": "string"
        }
      }
    }
    """
    And the schema "contact" has a group "contact_methods" with the following subschemas:
      | email_addresses | telephones | contact_links |
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
      | title     | label         | email_address    | subject  | body             |
      | Email us  | Send an email | foo@example.com  | Your ref | Name and address |
    And I click to add another "contact_method"
    And I click on the "telephones" subschema
    And I fill in the "telephone" form with the following fields:
      | title            |
      | New phone number |
    And I add the following "telephone_numbers" to the form:
      | label       | telephone_number | type      |
      | Telephone 1 | 12345            | Telephone |
      | Telephone 2 | 6789             | Textphone |
    And I indicate that the video relay service info should be displayed
    And I provide custom video relay service info where available
    And I indicate that the call charges info URL should be shown
    And I change the call charges info URL from its default value
    And I change the call charges info label from its default value
    And I indicate that BSL guidance should be shown
    And I change the BSL guidance label from its default value
    And I indicate that the opening hours should be shown
    And I input the opening hours
    And I save and continue
    And I click to add another "contact_method"
    And I click on the "contact_links" subschema
    And I fill in the "contact_link" form with the following fields:
      | title              | label      | url                | description |
      | Contact Form       | Contact Us | http://example.com | Description |
    When I save and continue
    Then I should be on the "add_group_contact_methods" step
    When I save and continue
    And I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a new "contact"
    When I click to view the content block
    And I should see the created embedded object of type "email_address"
    And I should see the created embedded object of type "telephone"
    And I should see the created embedded object of type "contact_link"
    When I view all the telephone attributes
    Then I should see that the call charges fields have been changed
    And I should see that the video relay service info is to be shown
    And I should see that the custom video relay info has been recorded
    And I should see that the BSL guidance fields have been changed

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
