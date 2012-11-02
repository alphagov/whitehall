Feature: Administering Roles
  This feature allows the administration of the various different roles in the system

Background:
  Given I am an admin

Scenario: Adding a traffic commissioner roles
  Given the organisation "Department for Transport" exists
  And a person called "Terence Traffic"
  When I add a new "Traffic commissioner" role named "Traffic Commissioner for Scotland" to the "Department for Transport"
  Then I should be able to appoint "Terence Traffic" to the new role
  And I should see "Terence Traffic" listed on the "Department for Transport" organisation page
