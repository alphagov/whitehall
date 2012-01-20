Feature: Featuring news articles

Background:
  Given I am an editor

Scenario: Featuring a news article
  Given a published news article "My News Article" exists
  When I feature the news article "My News Article"
  Then the news article "My News Article" should be featured on the public news and speeches page

Scenario: Unfeaturing a news article
  Given a featured news article "My News Article" exists
  When I unfeature the news article "My News Article"
  Then the news article "My News Article" should not be featured on the public news and speeches page
