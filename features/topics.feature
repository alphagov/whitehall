Feature: Policy Areas

  As an editor
  I want to be able to edit the description text of a policy area
  So that it best represents the policies that it gathers

Background:
  Given I am an editor

Scenario: Adding a new policy area
  When I create a new policy area "Flying monkeys" with description "Fly my pretties!"
  Then I should see in the admin the "Flying monkeys" policy area description is "Fly my pretties!"

Scenario: Adding a new policy area related to another policy area
  When I create a new policy area "Flying monkeys" related to policy area "No more beards"
  Then I should see in the admin the "Flying monkeys" policy area is related to policy area "No more beards"

Scenario: Editing the description
  Given a policy area called "No more beards" with description "No more hairy-faced men"
  When I edit the policy area "No more beards" to have description "No more hairy-faced people"
  Then I should see in the admin the "No more beards" policy area description is "No more hairy-faced people"

Scenario: Deleting a policy area
  Given a policy area called "No more beards" with description "No more hairy-faced men"
  Then I should be able to delete the policy area "No more beards"

Scenario: Choosing and ordering lead organisations within a policy area
  Given a policy area called "Facial Hair" with description "Against All Follicles"
  And the policy area "Facial Hair" has "Ministry of Grooming" as a lead organisation
  And the policy area "Facial Hair" has "Ministry of War" as a lead organisation
  And the policy area "Facial Hair" is associated with organisation "Department of Scissors and Wax"
  And the policy area "Facial Hair" is associated with organisation "Ministry of Sideburns"
  When I set the order of the lead organisations in the "Facial Hair" policy area to:
    |Organisation|
    |Ministry of Sideburns|
    |Department of Scissors and Wax|
    |Ministry of Grooming|
  Then I should see the order of the lead organisations in the "Facial Hair" policy area is:
    |Ministry of Sideburns|
    |Department of Scissors and Wax|
    |Ministry of Grooming|
  And I should see the following organisations for the "Facial Hair" policy area:
    |Ministry of War|

Scenario: Viewing the list of policy areas
  Given a policy area called "Higher Education" exists
  And a policy area called "Science and Innovation" exists
  When I visit the list of policy areas
  Then I should see the policy areas "Higher Education" and "Science and Innovation"

Scenario: Visiting a policy area page
  Given a policy area called "Higher Education" exists
  And a policy area called "Science and Innovation" exists
  And the policy area "Higher Education" is related to the policy area "Scientific Research"
  When I visit the "Higher Education" policy area
  Then I should see a link to the related policy area "Scientific Research"

Scenario: Featuring content on a policy area page
  Given a published publication "Cold fusion" with a PDF attachment
  And a policy area called "Science and Innovation" exists
  And the publication "Cold fusion" is associated with the policy area "Science and Innovation"
  When I feature the publication "Cold fusion" on the policy area "Science and Innovation"
  Then I should see the publication "Cold fusion" featured on the public policy area page for "Science and Innovation"

Scenario: Creating offsite content on a policy area page
  Given a policy area called "Excellent policy area" exists
  When I add the offsite link "Offsite Thing" of type "Alert" to the policy area "Excellent policy area"
  Then I should see the edit offsite link "Offsite Thing" on the "Excellent policy area" policy area page

Scenario: Featuring offsite content on a policy area page
  Given a policy area called "Excellent policy area" exists
  And I have an offsite link "Offsite Thing" for the policy area "Excellent policy area"
  When I feature the offsite link "Offsite Thing" for policy area "Excellent policy area" with image "minister-of-funk.960x640.jpg"
  Then I should see the offsite link featured on the public policy area page

Scenario: Adding featured links
  Given a policy area called "Housing prices" exists
  When I add some featured links to the policy area "Housing prices" via the admin
  Then the featured links for the policy area "Housing prices" should be visible on the public site
