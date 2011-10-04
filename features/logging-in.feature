Feature: Logging in
As a user
I want to be able to login and log out
So that I can manage my access to the application

Scenario: The admin root should have a login link
  Given I am on the policies admin page
  Then I should be given the opportunity to login

Scenario: Logged-in users should see they are logged in
  Given I am a writer called "Dave"
  Then I should see that I am logged in as "Dave"

Scenario: Logged-in users should be able to logout
  Given I am a writer
  And I logout
  And I should see that I am not logged in

Scenario: Don't show a login link on the login page
  Given I am on the login page
  Then I should not see a link to login

Scenario: Logged in writers should see their role
  Given I am a writer
  Then I should see that I am logged in as a policy writer

Scenario: Logged in editors should see their role
  Given I am an editor
  Then I should see that I am logged in as a departmental editor
