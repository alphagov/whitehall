Feature:
  As a user
  I want to be able to administer my details in application
  So that I can ensure I am in the right department, etc

Scenario: Logged in writers should see their role
  Given I am a writer
  Then I should see that I am logged in as a "Policy Writer"

Scenario: Logged in editors should see their role
  Given I am an editor
  Then I should see that I am logged in as a "Departmental Editor"

Scenario: Logged in users should be able to set their email address
  Given I am a writer called "John Smith"
  When I set the email address for "John Smith" to "writer@example.com"
  Then I should see my email address is "writer@example.com"

Scenario: Logged in users should be able to set their organisation
  Given I am a writer called "John Smith"
  And the organisation "Department of Beards" exists
  When I set the organisation for "John Smith" to "Department of Beards"
  Then I should see my organisation is "Department of Beards"

Scenario: Logged in users should be able to set their role
  Given I am a writer called "John Smith"
  When I set the role for "John Smith" to departmental editor
  Then I should see that I am a departmental editor

Scenario: Logged in users should be able to see other users' contact details
  Given I am a writer
  And there is a user called "John Smith" with email address "johnsmith@example.com"
  When I visit the admin author page for "John Smith"
  Then I should see an email address "johnsmith@example.com"
