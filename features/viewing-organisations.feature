Feature: Viewing organisations

Scenario: Organisation page should show policies
  Given the organisation "Attorney General's Office" contains some policies
  And other organisations also have policies
  When I visit the "Attorney General's Office" organisation
  Then I should only see published policies belonging to the "Attorney General's Office" organisation

Scenario: Organisation page should show ministers
  Given the "Attorney General's Office" organisation contains:
    | Role              | Person          |
    | Attorney General  | Colonel Mustard |
    | Solicitor General | Professor Plum  |
  When I visit the "Attorney General's Office" organisation
  Then I should see "Colonel Mustard" has the "Attorney General" role
  And I should see "Professor Plum" has the "Solicitor General" role
