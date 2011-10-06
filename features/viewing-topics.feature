Feature: Viewing topics

Scenario: Viewing a list of topics
  Given the topic "Higher Education" contains some policies
  And the topic "Science and Innovation" contains some policies
  When I visit the list of topics
  Then I should see the topics "Higher Education" and "Science and Innovation"

Scenario: Visiting a topic page
  Given the topic "Higher Education" contains some policies
  And other topics also have policies
  When I visit the "Higher Education" topic
  Then I should only see published policies belonging to the "Higher Education" topic