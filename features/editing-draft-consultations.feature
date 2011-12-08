Feature: editing draft consultations

Scenario: Creating a new draft consultation
  Given I am a writer
  When I draft a new consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of draft documents

Scenario: Submitting a draft consultation to a second pair of eyes
  Given I am a writer
  And a draft consultation "Beard Length Review" exists
  When I submit the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of submitted documents