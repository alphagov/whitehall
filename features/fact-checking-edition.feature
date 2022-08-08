Feature: Fact checking an edition

Scenario: Requesting a fact check
  Given I am a writer
  And I have the "View move tabs to endpoints" permission
  When I visit the edition show page
  Then the "Fact checking" tab is not visible
  When I visit the edit edition page
  Then the "Fact checking" tab is not visible
  When I add a french translation
  Then the "Fact checking" tab is not visible
  When I request a review from "not-a-real-email-address@email.com" with the instructions "please fact check when you can" for the document "Badddly Rittin"
  Then I should see I have a pending fact check request
