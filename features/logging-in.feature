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

Scenario: Logged in writers should see their role
  Given I am a writer
  Then I should see that I am logged in as a policy writer

Scenario: Logged in editors should see their role
  Given I am an editor
  Then I should see that I am logged in as a departmental editor

Scenario: Logged in users should be able to set their email address
  Given I am a writer called "John Smith"
  When I set the email address for "John Smith" to "writer@example.com"
  Then I should see my email address is "writer@example.com"

Scenario: Users who are not logged in should be taken to their original destination once they have logged in
  Given I try to access a page that requires authentication
  Then I should be asked to login
  When I login as a writer
  And I should be taken to my original destination