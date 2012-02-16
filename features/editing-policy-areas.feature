Feature: As an editor
I want to be able to edit the description text of a policy topic
So that it best represents the policies that it gathers

Background:
  Given I am an editor

Scenario: Adding a new policy topic
  When I create a new policy topic "Flying monkeys" with description "Fly my pretties!"
  Then I should see in the admin the "Flying monkeys" policy topic description is "Fly my pretties!"

Scenario: Adding a new policy topic related to another policy topic
  When I create a new policy topic "Flying monkeys" related to policy topic "No more beards"
  Then I should see in the admin the "Flying monkeys" policy topic is related to policy topic "No more beards"

Scenario: Editing the description
  Given a policy topic called "No more beards" with description "No more hairy-faced men"
  When I edit the policy topic "No more beards" to have description "No more hairy-faced people"
  Then I should see in the admin the "No more beards" policy topic description is "No more hairy-faced people"

Scenario: Deleting a policy topic
  Given a policy topic called "No more beards" with description "No more hairy-faced men"
  Then I should be able to delete the policy topic "No more beards"

Scenario: Ordering policies within a policy topic
  Given a policy topic called "Facial Hair" with description "Against All Follicles"
  And a published policy "Outlaw Moustaches" exists in the "Facial Hair" policy topic
  And a published policy "No more beards" exists in the "Facial Hair" policy topic
  And a published policy "Free monobrow treatment" exists in the "Facial Hair" policy topic
  When I set the order of the policies in the "Facial Hair" policy topic to:
    |Policy Area|
    |No more beards|
    |Outlaw Moustaches|
    |Free monobrow treatment|
  Then I should see the order of the policies in the "Facial Hair" policy topic is:
    |No more beards|
    |Outlaw Moustaches|
    |Free monobrow treatment|

Scenario: Featuring policies in a policy topic
  Given a policy topic called "Facial Hair" with description "Against All Follicles"
  And a published policy "Outlaw Moustaches" exists in the "Facial Hair" policy topic
  And a published policy "No more beards" exists in the "Facial Hair" policy topic
  And a published policy "Free monobrow treatment" exists in the "Facial Hair" policy topic
  When I set the featured policies in the "Facial Hair" policy topic to:
    |Policy Area|
    |No more beards|
    |Free monobrow treatment|
  Then I should see the featured policies in the "Facial Hair" policy topic are:
    |No more beards|
    |Free monobrow treatment|