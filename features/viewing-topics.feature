Feature: Viewing topics

Scenario: Viewing a list of topics
  Given the topic "Higher Education" contains some policies
  And the topic "Science and Innovation" contains some policies
  When I visit the list of topics
  Then I should see the topics "Higher Education" and "Science and Innovation"

Scenario: Visiting a topic page
  Given the topic "Higher Education" contains some policies
  And the topic "Higher Education" is related to the topic "Scientific Research"
  And other topics also have policies
  When I visit the "Higher Education" topic
  Then I should only see published policies belonging to the "Higher Education" topic
  And I should see a link to the related topic "Scientific Research"

Scenario: Exemplary content for empty topics
  Given a topic called "Caprid welfare"
  And a topic called "Social care"
  And a topic called "Higher education"
  When I visit the "Caprid welfare" topic
  Then I should see a link to the topic "Social care"
  And I should see a link to the topic "Higher education"
