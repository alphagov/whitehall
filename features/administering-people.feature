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

@quarantine-files
Scenario: Images are virus-checked before publication
  When I add a new person called "Dave Cameroon"
  When I check the image for the new person
  Then the image will be quarantined for virus checking
  When the image has been virus-checked
  Then the virus checked image will be available for viewing
