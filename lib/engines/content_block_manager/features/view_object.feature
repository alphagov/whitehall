Feature: View a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists:
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
    And the schema has a subschema "rates":
    """
    {
      "type":"object",
      "required": ["title", "amount"],
      "properties": {
        "title": {
          "type": "string"
        },
        "amount": {
          "type": "string",
          "pattern": "£[0-9]+\\.[0-9]+"
        },
        "frequency": {
          "type": "string",
          "enum": [
            "a week",
            "a month"
          ]
        }
      }
    }
    """
    And a pension content block has been created
    And that pension has a rate with the following fields:
      | title   | amount  | frequency |
      | My rate | £123.45 | a week    |
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
    And a contact content block has been created

  Scenario: GDS Editor views a content object
    When I visit the Content Block Manager home page
    Then I should see the details for all documents
    When I click to view the document
    Then I should be taken back to the document page
    And I should see the details for the contact content block
    And I should see the contact created event on the timeline

  Scenario: GDS Editor views a content object using the content ID
    When I visit a block's content ID endpoint
    And I should see the details for the contact content block

  Scenario: GDS Editor views dependent Content
    Given dependent content exists for a content block
    When I visit the Content Block Manager home page
    And I click to view the document
    Then I should see the dependent content listed
    And I should see the rollup data for the dependent content

  @javascript
  Scenario: GDS Editor can copy embed code for a specific field
    When I visit the Content Block Manager home page
    When I click to view the document with title "My pension"
    And I click to copy the embed code for the pension "My pension", rate "My rate" and field "amount"
    Then the embed code should be copied to my clipboard

  Scenario: GDS Editor without javascript can see embed code
    When I visit the Content Block Manager home page
    When I click to view the document with title "My pension"
    Then the embed code for the content block "My pension", rate "My rate" and field "amount" should be visible
