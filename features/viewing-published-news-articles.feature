Feature: Viewing news articles

Scenario: Viewing a published news article with related policies
  Given a published news article "News 1" with related published policies "Policy 1" and "Policy 2"
  When I visit the news article "News 1"
  Then I can see links to the related published policies "Policy 1" and "Policy 2"

Scenario: Viewing a published news article with notes to editors
  Given a published news article "News 1" with notes to editors "Notes to editors"
  When I visit the news article "News 1"
  Then I should see the notes to editors "Notes to editors" for the news article

Scenario: Viewing a featured news article
  Given a published featured news article "Amazing News"
  When I visit the homepage
  Then I should see "Amazing News" in the list of featured news articles

Scenario: Limiting the number of featured news articles
  Given 4 published featured news articles
  When I visit the homepage
  Then I should only see the most recent 3 in the list of featured news articles