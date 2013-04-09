Feature: Viewing minister pages
As a citizen
I want to be able to view a page gathering information about a minister
So that I can see what government activities they are involved with

Scenario: The minister belongs to departments
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  When I visit the minister page for "Minister of Crazy"
  Then I should see that the minister is associated with the "Department of Woah"

Scenario: The minister has responsibilities through their role
  Given "Marty McFly" is the "Minister of Anachronisms" for the "Department of Temporal Affairs"
  And the role "Minister of Anachronisms" has the responsibilities "Chronometric stability"
  When I visit the minister page for "Minister of Anachronisms"
  Then I should see that the minister has responsibilities "Chronometric stability"

Scenario: Announcements by current and former ministers appear on the page
  Given I am an editor
  And "Don Deputy" is the "Deputy Prime Minister" for the "Cabinet Office"
  And "Harriet Home" is the "Home Secretary" for the "Cabinet Office"
  And a published news article "News from Don, Deputy PM" associated with "Don Deputy"
  And there is a reshuffle and "Harriet Home" is now "Deputy Prime Minister"
  And a published news article "News from Harriet, Deputy PM" associated with "Harriet Home"
  When I visit the minister page for "Deputy Prime Minister"
  Then I should see both the news articles for the Deputy Prime Minister role

Scenario: Viewing all ministers
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  And "Fred Bloggs" is the "Minister of Sane" for the "Department of Foo"
  When I visit the ministers page
  Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah"
  And I should see that "Fred Bloggs" is a minister in the "Department of Foo"

Scenario: Ministers show only once even if they have two roles
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  And "Johnny Macaroon" is the "Minister of Fun" for the "Department of Woah"
  When I visit the ministers page
  Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah" with role "Minister of Crazy, Minister of Fun"

Scenario: Viewing ministers and whips
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  And "Fred Bloggs" is a commons whip "Deputy Chief Whip, Comptroller of HM Household" for the "Department of Foo"
  When I visit the ministers page
  Then I should see that "Johnny Macaroon" is a minister in the "Department of Woah"
  And I should see that "Fred Bloggs" is a commons whip "Deputy Chief Whip, Comptroller of HM Household"
