Feature: Create a content object

  Scenario: GDS editor creates an object
    Given I am a GDS admin
    And a schema "email_address" exists
    And a schema "tax_rates" exists
    When I access the create object page
    Then I should see all the schemas listed