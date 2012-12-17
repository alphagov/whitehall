Feature: As an editor
I want to be able to edit the description text of a topic
So that it best represents the policies that it gathers

Background:
  Given I am an editor

Scenario: Adding a new topic
  When I create a new topic "Flying monkeys" with description "Fly my pretties!"
  Then I should see in the admin the "Flying monkeys" topic description is "Fly my pretties!"

Scenario: Adding a new topic related to another topic
  When I create a new topic "Flying monkeys" related to topic "No more beards"
  Then I should see in the admin the "Flying monkeys" topic is related to topic "No more beards"

Scenario: Editing the description
  Given a topic called "No more beards" with description "No more hairy-faced men"
  When I edit the topic "No more beards" to have description "No more hairy-faced people"
  Then I should see in the admin the "No more beards" topic description is "No more hairy-faced people"

Scenario: Deleting a topic
  Given a topic called "No more beards" with description "No more hairy-faced men"
  Then I should be able to delete the topic "No more beards"

Scenario: Ordering policies within a topic
  Given a topic called "Facial Hair" with description "Against All Follicles"
  And a published policy "Outlaw Moustaches" exists in the "Facial Hair" topic
  And a published policy "No more beards" exists in the "Facial Hair" topic
  And a published policy "Free monobrow treatment" exists in the "Facial Hair" topic
  When I set the order of the policies in the "Facial Hair" topic to:
    |Topic|
    |No more beards|
    |Outlaw Moustaches|
    |Free monobrow treatment|
  Then I should see the order of the policies in the "Facial Hair" topic is:
    |No more beards|
    |Outlaw Moustaches|
    |Free monobrow treatment|

Scenario: Choosing and ordering lead organisations within a topic
  Given a topic called "Facial Hair" with description "Against All Follicles"
  And the topic "Facial Hair" has "Ministry of Grooming" as a lead organisation
  And the topic "Facial Hair" has "Ministry of War" as a lead organisation
  And the topic "Facial Hair" is associated with organisation "Department of Scissors and Wax"
  And the topic "Facial Hair" is associated with organisation "Ministry of Sideburns"
  When I set the order of the lead organisations in the "Facial Hair" topic to:
    |Organisation|
    |Ministry of Sideburns|
    |Department of Scissors and Wax|
    |Ministry of Grooming|
  Then I should see the order of the lead organisations in the "Facial Hair" topic is:
    |Ministry of Sideburns|
    |Department of Scissors and Wax|
    |Ministry of Grooming|
  And I should see the following organisations for the "Facial Hair" topic:
    |Ministry of War|
