Feature: Viewing all people page
As a citizen
I want to be able to view a page listing all ministers & senior officials on Inside Government
So that I can find a specific person

Background:
  Given I am an admin

Scenario: Viewing the person page for a person
  Given a person called "Benjamin Disraeli"
  When I visit the person page for "Benjamin Disraeli"
  Then I should see information about the person "Benjamin Disraeli"

Scenario: Announcements by that person over their career are shown
  Given I am an editor
  And "Don Deputy" is the "Deputy Prime Minister" for the "Cabinet Office"
  And "Harriet Home" is the "Home Secretary" for the "Cabinet Office"
  And a published news article "News from Harriet, Home Sec" associated with "Harriet Home"
  And there is a reshuffle and "Harriet Home" is now "Deputy Prime Minister"
  And a published news article "News from Harriet, Deputy PM" associated with "Harriet Home"
  When I visit the person page for "Harriet Home"
  Then I should see both the news articles for Harriet Home

Scenario: Viewing the person page for a worldwide person
  Given the worldwide organisation "British Embassy, Drexciya" exists
  And a person called "Gerald Stinson" is assigned as its ambassador "Ambassador to Drexciya"
  Then I should see the worldwide organisation listed on his public page

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

Scenario: Adding a new translation
  Given a person called "Amanda Appleford" exists with the biography "She was born. She lived. She died."
  When I add a new "Français" translation to the person "Amanda Appleford" with:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |
  Then when viewing the person "Amanda Appleford" with the locale "Français" I should see:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |

Scenario: Editing an existing translation
  Given a person called "Amanda Appleford" exists with a translation for the locale "Français"
  When I edit the "Français" translation for the person called "Amanda Appleford" setting:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |
  Then when viewing the person "Amanda Appleford" with the locale "Français" I should see:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |

Scenario: Viewing a person that previously had a role
  Given "Dale Cooper" is a minister with a history
  When I visit the person page for "Dale Cooper"
  Then I should see limited information about the person "Dale Cooper"
