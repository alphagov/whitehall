Feature: Create a content object

  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists with the following fields:
      | field         | type   | format | required |
      | description   | string | string | true     |
    And the schema "pension" has a subschema with the name "rates" and the following fields:
      | field     | type   | format | required | enum           | pattern          |
      | name      | string | string | true     |                |                  |
      | amount    | string | string | true     |                | £[0-9]+\\.[0-9]+ |
      | cadence   | string | string |          | a week,a month |                  |

  Scenario: GDS editor creates a Pension
    When I visit the Content Block Manager home page
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "pension" schema
    Then I should see a form for the schema
    When I complete the form with the following fields:
      | title            | description   | organisation        | instructions_to_publishers |
      | my basic pension | this is basic | Ministry of Example | this is important  |
    Then I should be on the "embedded_rates" step
    When I save and continue
    Then I am asked to review my answers for a "pension"
    And I review and confirm my answers are correct
    Then the edition should have been created successfully
    And I should be taken to the confirmation page for a new "pension"
