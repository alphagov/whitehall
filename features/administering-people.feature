Feature: administer people who can hold ministerial/other roles

Background:
  Given I am an admin

Scenario: Adding a person
  When I add a new person called "Dave Cameroon"
  Then I should be able to see "Dave Cameroon" in the list of people

Scenario: Editing a person
  Given a person called "Dave Camerine"
  When I update the person called "Dave Camerine" to have the name "Nick Clogg"
  Then I should be able to see "Nick Clogg" in the list of people

Scenario: Removing a person
  Given a person called "Liam Fixx"
  When I remove the person "Liam Fixx"
  Then I should not be able to see "Liam Fixx" in the list of people