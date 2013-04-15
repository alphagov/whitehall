Feature: Editing draft speeches

Scenario: Creating a new draft speech
  Given I am a writer
  When I draft a new speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of draft documents

Scenario: Editing an existing draft speech
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  When I edit the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  Then I should see the speech "Ban Moustaches" in the list of draft documents

Scenario: Creating a speech related to multiple policies
  Given I am a writer
  And two published policies "Against All Cods" and "O For Tuna" exist
  When I draft a new speech "Fishy Business" relating it to the policies "Against All Cods" and "O For Tuna"
  Then I should see in the preview that "Fishy Business" should related to "Against All Cods" and "O For Tuna" policies

Scenario: Creating a speech related to multiple worldwide prioirites
  Given I am a writer
  And a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new speech "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

Scenario: Trying to save a speech that has been changed by another user
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  And I start editing the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  And another user edits the speech "Outlaw Moustaches" changing the title to "Ban Beards"
  When I save my changes to the speech
  Then I should see the conflict between the speech titles "Ban Moustaches" and "Ban Beards"
  When I edit the speech changing the title to "Ban Moustaches and Beards"
  Then I should see the speech "Ban Moustaches and Beards" in the list of draft documents

Scenario: Submitting a draft speech to a second pair of eyes
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  When I submit the speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of submitted documents

@javascript
Scenario: Creating authored articles (originally published externally)
  Given I am an editor
  When I draft a new authored article "Colonel Mustard talks about beards to The Times"
  Then I should be able to choose who wrote the article
  And I should be able to choose the date it was written on
  But I cannot choose a location for the article

Scenario: Viewing authored articles (originally published externally)
  Given I am an editor
  When I draft a new authored article "Colonel Mustard talks about beards to The Times"
  And I preview the authored article
  Then I should see who wrote it clearly labelled in the metadata
