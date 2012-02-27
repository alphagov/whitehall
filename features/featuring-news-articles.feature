Feature: Featuring news articles

Background:
  Given I am an editor

Scenario: Featuring a news article
  Given a published news article "My News Article" exists
  When I feature the news article "My News Article"

Scenario: Unfeaturing a news article
  Given a featured news article "My News Article" exists
  When I unfeature the news article "My News Article"
