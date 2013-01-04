Feature: User administration
  As a user
  I want to be able to administer my details in application
  So that I can ensure I am in the right department, etc

  - Users have the ability to edit their own email address, but not their organisation
  - Only GDS editors can change users' organisations
  - GDS editors are able to see a list of users to allow them to easily operate on their records

Scenario: Logged in writers should see their role
  Given I am a writer
  Then I should see that I am logged in as a "Policy Writer"

Scenario: Logged in editors should see their role
  Given I am an editor
  Then I should see that I am logged in as a "Departmental Editor"

Scenario: Logged in GDS editors should see their role
  Given I am a GDS editor
  Then I should see that I am logged in as a "GDS Editor"

Scenario: Logged in users should be able to view but not edit their record
  Given I am a writer called "John Smith"
  And the organisation "Department of Beards" exists
  When I view my own user record
  Then I can see my user details
  But I cannot change my user details

Scenario: Logged in GDS editors can edit other users organisations
  Given I am a GDS editor
  And there is a user called "John Smith"
  And the organisation "Department of Beards" exists
  When I visit the user list in the admin section
  Then I should see "John Smith" in the user list
  When I set the organisation for "John Smith" to "Department of Beards"
  Then the organisation for "John Smith" is "Department of Beards"

Scenario: Logged in users should be able to see other users' contact details
  Given I am a writer
  And there is a user called "John Smith" with email address "johnsmith@example.com"
  When I visit the admin author page for "John Smith"
  Then I should see an email address "johnsmith@example.com"
