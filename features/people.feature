Feature: Viewing all people page
As a citizen
I want to be able to view a page listing all ministers & senior officials on Inside Government
So that I can find a specific person

Scenario: Viewing all people
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  And "Fred Bloggs" is the "Minister of Sane" for the "Department of Foo"
  When I visit the people page
  Then I should see that "Johnny Macaroon" is listed under "m"
  And I should see that "Fred Bloggs" is listed under "b"

Scenario: Viewing the person page for a minister
  Given "Benjamin Disraeli" is a minister with a history
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
