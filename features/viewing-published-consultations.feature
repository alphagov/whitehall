Feature: Viewing published consultations

Scenario: Viewing a featured consultation
  Given a published featured consultation "Should snow be mandatory at Christmas?"
  When I visit the consultations page
  Then I should see "Should snow be mandatory at Christmas?" in the list of featured consultations

Scenario: Limiting the number of featured consultations
  Given 2 published featured consultations
  When I visit the consultations page
  Then I should only see the most recent 1 in the list of featured consultations