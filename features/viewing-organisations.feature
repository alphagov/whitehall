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

Scenario: Organisation page should show the top minister
  Given the "Attorney General's Office" organisation is associated with several ministers and civil servants
  When I visit the "Attorney General's Office" organisation
  Then I should see the top minister for the "Attorney General's Office" organisation
  And I should see the top civil servant for the "Attorney General's Office" organisation
  And I should be able to view all ministers for the "Attorney General's Office" organisation on a separate page

Scenario: A department is responsible for multiple agencies
  Given that "BIS" is responsible for "Companies House" and "UKTI"
  When I visit the "BIS" organisation
  And I navigate to the "BIS" organisation's Agencies & partners page
  Then I should see that "BIS" is responsible for "Companies House"
  And I should see that "BIS" is responsible for "UKTI"

Scenario: Navigating between pages for an organisation
  Given the organisation "Cabinet Office" exists
  When I visit the "Cabinet Office" organisation
  Then I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's About page
  Then I should see the "Cabinet Office" organisation's about page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's Policies page
  Then I should see the "Cabinet Office" organisation's policies page
  And I should see the organisation navigation
  When I navigate to the "Cabinet Office" organisation's Home page
  Then I should see the "Cabinet Office" organisation's home page
  When I navigate to the "Cabinet Office" organisation's Agencies & partners page
  Then I should see the "Cabinet Office" organisation's Agencies & partners page
  And I should see the organisation navigation
