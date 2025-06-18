Feature: Drafting a content block

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
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "pension" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |

  Scenario: GDS editor cancels the creation of an object
    And I click cancel
    Then I am taken back to Content Block Manager home page
    And no draft Content Block Edition has been created
    And no draft Content Block Document has been created

  Scenario: Draft documents are not listed
    And I visit the Content Block Manager home page
    Then I should not see the draft document
