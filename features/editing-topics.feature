Feature: As an editor
I want to be able to edit the description text of a topic
So that it best represents the policies that it gathers

Background:
  Given I am an editor

Scenario: Adding a new topic
  When I create a new topic "Flying monkeys" with description "Fly my pretties!"
  Then I should see in the admin the "Flying monkeys" topic description is "Fly my pretties!"

Scenario: Editing the description
  Given a topic called "No more beards" with description "No more hairy-faced men"
  When I edit the topic "No more beards" to have description "No more hairy-faced people"
  Then I should see the "No more beards" topic description is "No more hairy-faced people"

Scenario: Deleting a topic
  Given a topic called "No more beards" with description "No more hairy-faced men"
  Then I should be able to delete the topic "No more beards"