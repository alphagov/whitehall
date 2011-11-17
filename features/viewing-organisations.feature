Feature: Viewing organisations

Scenario: Organisation page should show policies
  Given the organisation "Attorney General's Office" contains some policies
  And other organisations also have policies
  When I visit the "Attorney General's Office" organisation
  Then I should only see published policies belonging to the "Attorney General's Office" organisation

Scenario: Organisation page should show ministers
  Given the "Attorney General's Office" organisation contains:
    | Ministerial Role  | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |
  When I visit the "Attorney General's Office" organisation
  Then I should see "Colonel Mustard" has the "Attorney General" ministerial role
  And I should see "Professor Plum" has the "Solicitor General" ministerial role

Scenario: A department is responsible for multiple agencies
  Given that "BIS" is responsible for "Companies House" and "UKTI"
  When I visit the "BIS" organisation
  Then I should see that "BIS" is responsible for "Companies House"
  And I should see that "BIS" is responsible for "UKTI"

Scenario: An agency if the responsibility of multiple departments
  Given that "The stabilisation unit" is the responsibility of "DFID" and "FCO"
  When I visit the "The stabilisation unit" organisation
  Then I should see that "The stabilisation unit" is the responsibility of "DFID"
  And I should see that "The stabilisation unit" is the responsibility of "FCO"