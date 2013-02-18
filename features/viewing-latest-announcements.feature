Feature: Viewing latest announcements

@not-quite-as-fake-search
Scenario: There are both speeches and news items
  Given a published news article "News 1" exists
  And a published speech "Speech 1" exists
  When I visit the list of announcements
  Then I should see the news article "News 1"
  And I should see the speech "Speech 1"