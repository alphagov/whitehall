Feature: Reviewing speeches

Scenario: Viewing a speech that's been submitted for review
  Given "Ben Beardson" submitted a speech "Legalise beards" with body "Beards for everyone!"
  When I visit the list of speeches awaiting review
  And I view the speech "Legalise beards"
  And I should see that "Beards for everyone!" is the speech body
