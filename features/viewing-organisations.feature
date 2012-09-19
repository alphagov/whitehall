Feature: Viewing organisations

Scenario: Organisation page should show policies
  Given the organisation "Attorney General's Office" contains some policies
  And other organisations also have policies
  When I visit the "Attorney General's Office" organisation
  Then I should only see published policies belonging to the "Attorney General's Office" organisation

Scenario: Organisation page should show consultations
  Given the organisation "Attorney General's Office" is associated with consultations "More tea vicar?" and "Cake or biscuit?"
  When I visit the "Attorney General's Office" organisation
  Then I can see links to the consultations "More tea vicar?" and "Cake or biscuit?"

Scenario: Organisation page should show the ministers
  Given the "Attorney General's Office" organisation is associated with several ministers and civil servants
  When I visit the "Attorney General's Office" organisation
  And I should see the top civil servant for the "Attorney General's Office" organisation
  And I should be able to view all ministers for the "Attorney General's Office" organisation
