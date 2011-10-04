Feature: Viewing topics

Scenario: Visiting a topic page
  Given the topic "Higher Education" contains some policies
  And other topics also have policies
  When I visit the "Higher Education" topic
  Then I should only see published policies belonging to the "Higher Education" topic