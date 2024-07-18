Feature: Administering Roles
  This feature allows the administration of the various different roles in the system

  Background:
    Given I am an admin
    And the editionable worldwide organisation feature flag is disabled

  Scenario: Adding a traffic commissioner role
    Given the organisation "Department for Transport" exists
    And a person called "Terence Traffic"
    When I add a new "Traffic commissioner" role named "Traffic Commissioner for Scotland" to the "Department for Transport"
    Then I should be able to appoint "Terence Traffic" to the new role

  Scenario: Adding a chief scientist
    Given the organisation "Foreign Office" exists
    And a person called "Susan Scientist"
    When I add a new "Chief scientific advisor" role named "Chief Scientific Advisor to the FCO" to the "Foreign Office"
    Then I should be able to appoint "Susan Scientist" to the new role
