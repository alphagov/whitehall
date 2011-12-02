Feature: Viewing news articles

Scenario: Viewing a published news article with related policies
  Given a published news article "News 1" with related published policies "Policy 1" and "Policy 2"
  When I visit the news article "News 1"
  Then I can see links to the related published policies "Policy 1" and "Policy 2"

Scenario: Viewing a published news article with notes to editors
  Given a published news article "News 1" with notes to editors "Notes to editors"
  When I visit the news article "News 1"
  Then I should see the notes to editors "Notes to editors" for the news article