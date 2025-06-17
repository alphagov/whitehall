Feature: Validating a content block

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

  Scenario: GDS editor sees validation errors when not selecting an object type
    When I visit the Content Block Manager home page
    And I click to create an object
    And I click save
    Then I should see an error prompting me to choose an object type

  Scenario: GDS editor sees validation errors for missing fields
    When I visit the Content Block Manager home page
    And I click to create an object
    When I click on the "pension" schema
    And I click save
    Then I should see errors for the required fields

  Scenario: GDS editor sees validation errors for unconfirmed answers
    And I visit the Content Block Manager home page
    And I click to create an object
    And I click on the "pension" schema
    And I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    Then I am asked to review my answers for a "pension"
    When I click publish without confirming my details
    Then I should see a message that I need to confirm the details are correct
