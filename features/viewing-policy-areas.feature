Feature: Viewing policy areas

Scenario: Viewing a list of policy areas
  Given the policy area "Higher Education" contains some policies
  And the policy area "Science and Innovation" contains some policies
  When I visit the list of policy areas
  Then I should see the policy areas "Higher Education" and "Science and Innovation"

Scenario: Visiting a policy area page
  Given the policy area "Higher Education" contains some policies
  And other policy areas also have policies
  When I visit the "Higher Education" policy area
  Then I should only see published policies belonging to the "Higher Education" policy area