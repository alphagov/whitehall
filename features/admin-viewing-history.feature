Feature: Viewing a document's history

Scenario: Viewing history with the View move tabs to endpoints permission
  Given I am a writer
  And I have the "View move tabs to endpoints" permission
  When I visit the edition show page
  Then the "History" tab is not visible
  When I visit the edit edition page
  Then the "History" tab is not visible
  When I add a french translation
  Then the "History" tab is not visible
  When I visit the history page
  Then I should be able to see the document's history
