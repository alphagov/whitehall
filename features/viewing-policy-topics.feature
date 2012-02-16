Feature: Viewing policy topics

Scenario: Viewing a list of policy topics
  Given the policy topic "Higher Education" contains some policies
  And the policy topic "Science and Innovation" contains some policies
  When I visit the list of policy topics
  Then I should see the policy topics "Higher Education" and "Science and Innovation"

Scenario: Visiting a policy topic page
  Given the policy topic "Higher Education" contains some policies
  And the policy topic "Higher Education" is related to the policy topic "Scientific Research"
  And other policy topics also have policies
  When I visit the "Higher Education" policy topic
  Then I should only see published policies belonging to the "Higher Education" policy topic
  And I should see a link to the related policy topic "Scientific Research"
