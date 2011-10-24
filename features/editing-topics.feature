Feature: As an editor
I want to be able to edit the description text of a topic
So that it best represents the policies that it gathers

Scenario: Editing the description
  Given I am an editor
  And a topic called "No more beards" with description "No more hairy-faced men"
  When I edit the topic "No more beards" to have description "No more hairy-faced people"
  Then I should see the "No more beards" topic description is "No more hairy-faced people"