Feature: Announcements

Background:
  Given I can navigate to the list of announcements

@not-quite-as-fake-search
Scenario: Viewing news articles and speeches together on the news and speeches page
  Given a published news article "Crackdown on tax avoidance" exists
  And a published speech "Minister announces crackdown on tax avoidance" exists
  When I visit the list of announcements
  Then I should see the news article "Crackdown on tax avoidance" in the list of announcements
  And I should see the speech "Minister announces crackdown on tax avoidance" in the list of announcements
