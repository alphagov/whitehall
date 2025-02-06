Feature: Create an embedded content object

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
      | cadence   | string | string |          | weekly,monthly |                  |
    And a pension content block has been created

  Scenario: GDS editor creates a rate
    When I visit the page to create a new "rate" for the block
    Then I should see a form to create a "rate" for the content block
    When I complete the "rate" form with the following fields:
      | name    | amount  | cadence |
      | my rate | £122.50 | weekly  |
    Then the "rate" should have been created successfully
    And I should see confirmation that my "rate" has been created
