Feature: Create a content object

  Scenario: GDS editor creates an object
    Given I am a GDS admin
    And a schema "email_address" exists with the following fields:
      | email_address |
      | department    |
    And a schema "tax_rates" exists with the following fields:
      | rate |
    When I visit the object store
    And I click to create an object
    Then I should see all the schemas listed
    When I click on the "email_address" schema
    Then I should see a form for the schema
    When I complete the form
    Then the edition should have been created successfully