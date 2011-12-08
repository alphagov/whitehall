Feature: Editing draft speeches

Background:
  Given I am a writer

Scenario: Creating a new draft speech
  When I draft a new speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of draft documents

Scenario: Editing an existing draft speech
  Given a draft speech "Outlaw Moustaches" exists
  When I edit the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  Then I should see the speech "Ban Moustaches" in the list of draft documents

Scenario: Creating a speech related to multiple policies
  Given two published policies "Against All Cods" and "O For Tuna" exist
  When I draft a new speech "Fishy Business" relating it to "Against All Cods" and "O For Tuna"
  Then I should see in the preview that "Fishy Business" should related to "Against All Cods" and "O For Tuna" policies

Scenario: Creating a speech related to different countries
  Given a country "England" exists
  And a country "Iceland" exists
  When I draft a new speech "For the love of cod" related to countries "England" and "Iceland"
  Then I should see in the preview that "For the love of cod" is related to countries "England" and "Iceland"

Scenario: Trying to save a speech that has been changed by another user
  Given a draft speech "Outlaw Moustaches" exists
  And I start editing the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  And another user edits the speech "Outlaw Moustaches" changing the title to "Ban Beards"
  When I save my changes to the speech
  Then I should see the conflict between the speech titles "Ban Moustaches" and "Ban Beards"
  When I edit the speech changing the title to "Ban Moustaches and Beards"
  Then I should see the speech "Ban Moustaches and Beards" in the list of draft documents

Scenario: Submitting a draft speech to a second pair of eyes
  Given a draft speech "Outlaw Moustaches" exists
  When I submit the speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of submitted documents