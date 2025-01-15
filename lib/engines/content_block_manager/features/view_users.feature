Feature: View users
  Background:
    Given I am a GDS admin
    And A user exists with uuid "123"

  Scenario: GDS Editor views a user
    When I visit the user page for uuid "123"
    Then I should see the details for that user
