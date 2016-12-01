Feature: Topics

  As an editor
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

Scenario: Visiting a topic page
  Given a topic called "Higher Education" exists
  And a topic called "Science and Innovation" exists
  And the topic "Higher Education" is related to the topic "Scientific Research"
  When I visit the "Higher Education" topic
  Then I should see a link to the related topic "Scientific Research"

Scenario: Featuring content on a topic page
  Given a published publication "Cold fusion" with a PDF attachment
  And a topic called "Science and Innovation" exists
  And the publication "Cold fusion" is associated with the topic "Science and Innovation"
  When I feature the publication "Cold fusion" on the topic "Science and Innovation"
  Then I should see the publication "Cold fusion" featured on the public topic page for "Science and Innovation"

Scenario: Creating offsite content on a topic page
  Given a topic called "Excellent Topic" exists
  When I add the offsite link "Offsite Thing" of type "Alert" to the topic "Excellent Topic"
  Then I should see the edit offsite link "Offsite Thing" on the "Excellent Topic" topic page

Scenario: Featuring offsite content on a topic page
  Given a topic called "Excellent Topic" exists
  And I have an offsite link "Offsite Thing" for the topic "Excellent Topic"
  When I feature the offsite link "Offsite Thing" for topic "Excellent Topic" with image "minister-of-funk.960x640.jpg"
  Then I should see the offsite link featured on the public topic page

Scenario: Adding featured links
  Given a topic called "Housing prices" exists
  When I add some featured links to the topic "Housing prices" via the admin
  Then the featured links for the topic "Housing prices" should be visible on the public site
